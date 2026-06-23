class Api::V1::ReservationsController < ApplicationController
  before_action :set_reservation, only: [:show, :cancel]

  def index
    scope = Reservation.includes(:user, seat: :zone).all

    unless current_user.is_admin
      scope = scope.where(user: current_user)
    end

    scope = scope.where(seat_id: params[:seat_id]) if params[:seat_id].present?
    scope = scope.where(status: params[:status]) if params[:status].present?

    if params[:start_date].present? && params[:end_date].present?
      scope = scope.in_date_range(params[:start_date].to_date, params[:end_date].to_date)
    end

    render json: scope.order(created_at: :desc).map { |r| reservation_response(r) }, status: :ok
  end

  def show
    if !current_user.is_admin && @reservation.user_id != current_user.id
      return render json: { error: '无权访问此预约' }, status: :forbidden
    end

    render json: reservation_response(@reservation), status: :ok
  end

  def create
    reservation = current_user.reservations.new(reservation_params)

    if reservation.save
      render json: {
        message: '预约成功',
        reservation: reservation_response(reservation)
      }, status: :created
    else
      render json: { errors: reservation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def cancel
    if !current_user.is_admin && @reservation.user_id != current_user.id
      return render json: { error: '无权取消此预约' }, status: :forbidden
    end

    if @reservation.cancel
      render json: {
        message: '取消成功',
        reservation: reservation_response(@reservation)
      }, status: :ok
    else
      render json: { error: '无法取消此预约' }, status: :unprocessable_entity
    end
  end

  private

  def set_reservation
    @reservation = Reservation.includes(:user, seat: :zone).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: '预约不存在' }, status: :not_found
  end

  def reservation_params
    params.permit(:seat_id, :start_time, :end_time)
  end

  def reservation_response(reservation)
    {
      id: reservation.id,
      user_id: reservation.user_id,
      user_name: reservation.user.name,
      seat_id: reservation.seat_id,
      seat_number: reservation.seat.seat_number,
      zone_id: reservation.seat.zone_id,
      zone_name: reservation.seat.zone.name,
      zone_type: reservation.seat.zone.zone_type,
      start_time: reservation.start_time,
      end_time: reservation.end_time,
      duration_hours: reservation.duration_hours,
      total_amount: reservation.total_amount.to_f,
      status: reservation.status,
      can_cancel: reservation.can_cancel?,
      created_at: reservation.created_at
    }
  end
end
