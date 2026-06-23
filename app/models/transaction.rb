require 'ostruct'

class Transaction < ApplicationRecord
  TRANSACTION_TYPES = ['recharge', 'consumption', 'refund'].freeze

  belongs_to :user
  belongs_to :reservation, optional: true

  validates :transaction_type, presence: true, inclusion: { in: TRANSACTION_TYPES }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :balance_after, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :for_user, ->(user) { where(user: user) }
  scope :recharges, -> { where(transaction_type: 'recharge') }
  scope :consumptions, -> { where(transaction_type: 'consumption') }
  scope :refunds, -> { where(transaction_type: 'refund') }
  scope :in_date_range, ->(start_date, end_date) {
    where('created_at >= ? AND created_at <= ?', start_date, end_date)
  }

  def self.monthly_leaderboard(year, month, limit = 10)
    start_date = Date.new(year, month, 1).beginning_of_day
    end_date = start_date.end_of_month.end_of_day

    consumptions = joins(:user)
      .where(transaction_type: 'consumption')
      .where('transactions.created_at >= ? AND transactions.created_at <= ?', start_date, end_date)
      .includes(reservation: [:seat])

    user_stats = Hash.new do |h, k|
      h[k] = { user_id: nil, user_name: nil, total_hours: 0.0, total_spent: 0.0, reservation_count: 0 }
    end

    consumptions.each do |t|
      stats = user_stats[t.user_id]
      stats[:user_id] = t.user_id
      stats[:user_name] = t.user.name
      stats[:total_spent] += t.amount.to_f
      stats[:reservation_count] += 1
      if t.reservation
        stats[:total_hours] += t.reservation.duration_hours
      end
    end

    user_stats.values
      .sort_by { |s| -s[:total_hours] }
      .first(limit)
      .each_with_index
      .map do |stats, index|
        OpenStruct.new(
          user_id: stats[:user_id],
          user_name: stats[:user_name],
          total_hours: stats[:total_hours].round(2),
          total_spent: stats[:total_spent].round(2),
          reservation_count: stats[:reservation_count]
        )
      end
  end
end
