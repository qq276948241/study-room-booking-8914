class ApplicationController < ActionController::API
  before_action :authenticate_request
  attr_reader :current_user

  def authenticate_request
    header = request.headers['Authorization']
    token = header&.split(' ')&.last

    return render json: { error: '缺少认证令牌' }, status: :unauthorized unless token

    @current_user = User.find_by(auth_token: token)
    render json: { error: '无效的认证令牌' }, status: :unauthorized unless @current_user
  end

  def authenticate_admin
    render json: { error: '需要管理员权限' }, status: :forbidden unless current_user&.is_admin
  end
end
