class Api::V1::UsersController < ApplicationController
  before_action :authenticate_admin, only: [:index, :show, :update, :destroy]
  before_action :set_user, only: [:show, :update, :destroy]

  def index
    users = User.all
    render json: users.map { |user| user_response(user) }, status: :ok
  end

  def show
    render json: user_response(@user), status: :ok
  end

  def update
    if @user.update(user_params)
      render json: user_response(@user), status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: '用户不存在' }, status: :not_found
  end

  def user_params
    params.permit(:name, :phone, :balance, :is_admin)
  end

  def user_response(user)
    {
      id: user.id,
      name: user.name,
      phone: user.phone,
      balance: user.balance.to_f,
      is_admin: user.is_admin,
      reservation_count: user.reservations.count,
      total_spent: user.transactions.consumptions.sum(:amount).to_f,
      created_at: user.created_at
    }
  end
end
