class User < ApplicationRecord
  has_secure_password

  has_many :reservations, dependent: :destroy
  has_many :transactions, dependent: :destroy

  validates :name, presence: true
  validates :phone, presence: true, uniqueness: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  before_create :generate_auth_token

  def generate_auth_token
    self.auth_token = SecureRandom.hex(32)
  end

  def regenerate_auth_token
    update(auth_token: SecureRandom.hex(32))
  end

  def recharge(amount)
    return false if amount <= 0

    ActiveRecord::Base.transaction do
      self.balance += amount
      save!
      transactions.create!(
        transaction_type: 'recharge',
        amount: amount,
        balance_after: balance,
        description: "账户充值 #{amount} 元"
      )
    end
    true
  end

  def monthly_usage_stats(year, month)
    start_date = Date.new(year, month, 1).beginning_of_day
    end_date = start_date.end_of_month.end_of_day

    completed_reservations = reservations
      .where(status: 'completed')
      .where('start_time >= ? AND start_time <= ?', start_date, end_date)

    total_hours = completed_reservations.sum do |r|
      ((r.end_time - r.start_time) / 3600).round(2)
    end

    total_spent = completed_reservations.sum(:total_amount)

    {
      total_hours: total_hours,
      total_spent: total_spent,
      reservation_count: completed_reservations.count
    }
  end
end
