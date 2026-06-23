class Reservation < ApplicationRecord
  STATUSES = ['confirmed', 'completed', 'cancelled', 'no_show'].freeze

  belongs_to :user
  belongs_to :seat
  has_one :payment_transaction, class_name: 'Transaction', dependent: :destroy

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }

  validate :validate_time_range
  validate :validate_no_overlapping_reservations, on: :create
  validate :validate_balance_sufficient, on: :create

  before_validation :calculate_total_amount, on: :create
  after_create :deduct_balance_and_create_transaction

  scope :active, -> { where(status: ['confirmed', 'completed']) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_seat, ->(seat) { where(seat: seat) }
  scope :upcoming, -> { where('start_time > ?', Time.current) }
  scope :in_date_range, ->(start_date, end_date) {
    where('start_time >= ? AND end_time <= ?', start_date, end_date)
  }

  def cancel
    return false if status == 'cancelled' || status == 'completed'

    refund_amount = calculate_refund_amount

    ActiveRecord::Base.transaction do
      update!(status: 'cancelled')
      if refund_amount > 0
        user.update!(balance: user.balance + refund_amount)
        user.transactions.create!(
          transaction_type: 'refund',
          amount: refund_amount,
          balance_after: user.balance,
          reservation: self,
          description: "预约取消退款 #{refund_amount} 元"
        )
      end
    end
    true
  end

  def duration_hours
    ((end_time - start_time) / 3600).round(2)
  end

  def can_cancel?
    return false unless status == 'confirmed'

    start_time > Time.current
  end

  private

  def validate_time_range
    return if start_time.nil? || end_time.nil?

    errors.add(:end_time, '必须晚于开始时间') unless end_time > start_time
    errors.add(:start_time, '不能早于当前时间') if start_time < Time.current
    errors.add(:base, '预约时长不能超过24小时') if duration_hours > 24
  end

  def validate_no_overlapping_reservations
    return if seat.nil? || start_time.nil? || end_time.nil?

    overlapping = Reservation
      .where(seat: seat)
      .where(status: ['confirmed', 'completed'])
      .where('start_time < ? AND end_time > ?', end_time, start_time)

    if overlapping.exists?
      errors.add(:base, '该座位在所选时间段已被预约')
    end
  end

  def validate_balance_sufficient
    return if user.nil? || total_amount.nil?

    if user.balance < total_amount
      errors.add(:base, '余额不足，请先充值')
    end
  end

  def calculate_total_amount
    self.total_amount = (duration_hours * seat.zone.hourly_rate).round(2)
  end

  def deduct_balance_and_create_transaction
    ActiveRecord::Base.transaction do
      user.update!(balance: user.balance - total_amount)
      user.transactions.create!(
        transaction_type: 'consumption',
        amount: total_amount,
        balance_after: user.balance,
        reservation: self,
        description: "预约 #{seat.zone.name} #{seat.seat_number} 座位，时长 #{duration_hours} 小时"
      )
    end
  end

  def calculate_refund_amount
    hours_before = ((start_time - Time.current) / 3600).round(2)

    if hours_before >= 24
      total_amount
    elsif hours_before >= 1
      (total_amount * 0.5).round(2)
    else
      0
    end
  end
end
