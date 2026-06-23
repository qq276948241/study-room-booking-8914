class Zone < ApplicationRecord
  ZONE_TYPES = ['quiet', 'discussion', 'vip'].freeze

  has_many :seats, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :zone_type, presence: true, inclusion: { in: ZONE_TYPES }
  validates :hourly_rate, presence: true, numericality: { greater_than: 0 }

  scope :quiet_zones, -> { where(zone_type: 'quiet') }
  scope :discussion_zones, -> { where(zone_type: 'discussion') }
  scope :vip_zones, -> { where(zone_type: 'vip') }

  def available_seats(start_time, end_time)
    seat_ids = Reservation
      .where('status != ?', 'cancelled')
      .where('start_time < ? AND end_time > ?', end_time, start_time)
      .pluck(:seat_id)

    seats.where(is_active: true).where.not(id: seat_ids)
  end
end
