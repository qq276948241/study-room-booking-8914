class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_request, only: [:register, :login]

  def register
    user = User.new(user_params)

    if user.save
      render json: {
        message: '注册成功',
        user: user_response(user),
        token: user.auth_token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(phone: params[:phone])

    if user&.authenticate(params[:password])
      user.regenerate_auth_token
      render json: {
        message: '登录成功',
        user: user_response(user),
        token: user.auth_token
      }, status: :ok
    else
      render json: { error: '手机号或密码错误' }, status: :unauthorized
    end
  end

  def logout
    current_user.regenerate_auth_token
    render json: { message: '退出登录成功' }, status: :ok
  end

  def me
    render json: {
      user: user_response(current_user)
    }, status: :ok
  end

  private

  def user_params
    params.permit(:name, :phone, :password, :password_confirmation)
  end

  def user_response(user)
    {
      id: user.id,
      name: user.name,
      phone: user.phone,
      balance: user.balance.to_f,
      is_admin: user.is_admin,
      created_at: user.created_at
    }
  end
end
