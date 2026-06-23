class Api::V1::TransactionsController < ApplicationController
  def index
    scope = Transaction.includes(:user, :reservation).for_user(current_user)

    if current_user.is_admin && params[:user_id].present?
      scope = Transaction.includes(:user, :reservation).where(user_id: params[:user_id])
    end

    scope = scope.where(transaction_type: params[:type]) if params[:type].present?

    if params[:start_date].present? && params[:end_date].present?
      scope = scope.in_date_range(params[:start_date].to_date, params[:end_date].to_date)
    end

    render json: scope.order(created_at: :desc).limit(100).map { |t| transaction_response(t) }, status: :ok
  end

  def recharge
    amount = params[:amount]&.to_f

    if amount <= 0
      return render json: { error: '充值金额必须大于0' }, status: :bad_request
    end

    if current_user.recharge(amount)
      render json: {
        message: '充值成功',
        balance: current_user.balance.to_f,
        transaction: transaction_response(current_user.transactions.last)
      }, status: :ok
    else
      render json: { error: '充值失败' }, status: :unprocessable_entity
    end
  end

  def monthly_leaderboard
    year = params[:year]&.to_i || Date.current.year
    month = params[:month]&.to_i || Date.current.month
    limit = params[:limit]&.to_i || 10

    leaderboard = Transaction.monthly_leaderboard(year, month, limit)

    render json: {
      year: year,
      month: month,
      leaderboard: leaderboard.map.with_index do |entry, index|
        {
          rank: index + 1,
          user_id: entry.user_id,
          user_name: entry.user_name,
          total_hours: entry.total_hours.to_f.round(2),
          total_spent: entry.total_spent.to_f.round(2),
          reservation_count: entry.reservation_count
        }
      end
    }, status: :ok
  end

  def my_stats
    year = params[:year]&.to_i || Date.current.year
    month = params[:month]&.to_i || Date.current.month

    stats = current_user.monthly_usage_stats(year, month)

    render json: {
      year: year,
      month: month,
      stats: {
        total_hours: stats[:total_hours].to_f.round(2),
        total_spent: stats[:total_spent].to_f.round(2),
        reservation_count: stats[:reservation_count]
      }
    }, status: :ok
  end

  private

  def transaction_response(transaction)
    {
      id: transaction.id,
      user_id: transaction.user_id,
      user_name: transaction.user.name,
      transaction_type: transaction.transaction_type,
      amount: transaction.amount.to_f,
      balance_after: transaction.balance_after.to_f,
      description: transaction.description,
      reservation_id: transaction.reservation_id,
      created_at: transaction.created_at
    }
  end
end
