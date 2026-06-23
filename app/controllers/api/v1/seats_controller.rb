class Api::V1::SeatsController < ApplicationController
  before_action :authenticate_admin, only: [:create, :update, :destroy]
  before_action :set_seat, only: [:show, :update, :destroy, :availability]

  def index
    scope = Seat.includes(:zone).all
    scope = scope.where(zone_id: params[:zone_id]) if params[:zone_id].present?
    scope = scope.active if params[:active] == 'true'
    scope = scope.with_monitor if params[:has_monitor] == 'true'

    render json: scope.map { |seat| seat_response(seat) }, status: :ok
  end

  def show
    render json: seat_response(@seat), status: :ok
  end

  def create
    seat = Seat.new(seat_params)

    if seat.save
      render json: seat_response(seat), status: :created
    else
      render json: { errors: seat.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @seat.update(seat_params)
      render json: seat_response(@seat), status: :ok
    else
      render json: { errors: @seat.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @seat.destroy
    head :no_content
  end

  def availability
    start_time = params[:start_time]&.to_time
    end_time = params[:end_time]&.to_time

    if start_time.blank? || end_time.blank?
      return render json: { error: '请提供开始时间和结束时间' }, status: :bad_request
    end

    available = @seat.available?(start_time, end_time)
    render json: {
      seat_id: @seat.id,
      seat_number: @seat.seat_number,
      available: available,
      start_time: start_time,
      end_time: end_time
    }, status: :ok
  end

  private

  def set_seat
    @seat = Seat.includes(:zone).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: '座位不存在' }, status: :not_found
  end

  def seat_params
    params.permit(:zone_id, :seat_number, :has_monitor, :has_power_outlet, :equipment_notes, :is_active)
  end

  def seat_response(seat)
    {
      id: seat.id,
      seat_number: seat.seat_number,
      has_monitor: seat.has_monitor,
      has_power_outlet: seat.has_power_outlet,
      equipment_notes: seat.equipment_notes,
      is_active: seat.is_active,
      zone_id: seat.zone_id,
      zone_name: seat.zone.name,
      zone_type: seat.zone.zone_type,
      hourly_rate: seat.zone.hourly_rate.to_f,
      created_at: seat.created_at
    }
  end
end
