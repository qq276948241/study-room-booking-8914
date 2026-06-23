class Seat < ApplicationRecord
  belongs_to :zone
  has_many :reservations, dependent: :destroy

  validates :seat_number, presence: true, uniqueness: { scope: :zone_id }

  scope :active, -> { where(is_active: true) }
  scope :with_monitor, -> { where(has_monitor: true) }

  def available?(start_time, end_time)
    reservations
      .where('status != ?', 'cancelled')
      .where('start_time < ? AND end_time > ?', end_time, start_time)
      .none?
  end

  def current_reservation
    now = Time.current
    reservations
      .where('status != ?', 'cancelled')
      .where('start_time <= ? AND end_time >= ?', now, now)
      .order(:start_time)
      .first
  end
end
