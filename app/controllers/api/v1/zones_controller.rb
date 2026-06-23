class Api::V1::ZonesController < ApplicationController
  before_action :authenticate_admin, only: [:create, :update, :destroy]
  before_action :set_zone, only: [:show, :update, :destroy, :available_seats]

  def index
    zones = Zone.all
    render json: zones.map { |zone| zone_response(zone) }, status: :ok
  end

  def show
    render json: zone_response(@zone), status: :ok
  end

  def create
    zone = Zone.new(zone_params)

    if zone.save
      render json: zone_response(zone), status: :created
    else
      render json: { errors: zone.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @zone.update(zone_params)
      render json: zone_response(@zone), status: :ok
    else
      render json: { errors: @zone.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @zone.destroy
    head :no_content
  end

  def available_seats
    start_time = params[:start_time]&.to_time
    end_time = params[:end_time]&.to_time

    if start_time.blank? || end_time.blank?
      return render json: { error: '请提供开始时间和结束时间' }, status: :bad_request
    end

    seats = @zone.available_seats(start_time, end_time)
    render json: seats.map { |seat| seat_response(seat) }, status: :ok
  end

  private

  def set_zone
    @zone = Zone.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: '区域不存在' }, status: :not_found
  end

  def zone_params
    params.permit(:name, :zone_type, :hourly_rate, :description)
  end

  def zone_response(zone)
    {
      id: zone.id,
      name: zone.name,
      zone_type: zone.zone_type,
      hourly_rate: zone.hourly_rate.to_f,
      description: zone.description,
      seats_count: zone.seats.count,
      active_seats_count: zone.seats.active.count,
      created_at: zone.created_at
    }
  end

  def seat_response(seat)
    {
      id: seat.id,
      seat_number: seat.seat_number,
      has_monitor: seat.has_monitor,
      has_power_outlet: seat.has_power_outlet,
      equipment_notes: seat.equipment_notes,
      zone_id: seat.zone_id,
      zone_name: seat.zone.name
    }
  end
end
