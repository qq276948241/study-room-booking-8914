Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post 'auth/register', to: 'auth#register'
      post 'auth/login', to: 'auth#login'
      post 'auth/logout', to: 'auth#logout'
      get 'auth/me', to: 'auth#me'

      resources :zones, only: [:index, :show, :create, :update, :destroy] do
        get 'available_seats', on: :member
      end

      resources :seats, only: [:index, :show, :create, :update, :destroy] do
        get 'availability', on: :member
      end

      resources :reservations, only: [:index, :show, :create] do
        post 'cancel', on: :member
      end

      resources :transactions, only: [:index] do
        collection do
          post 'recharge'
          get 'monthly_leaderboard'
          get 'my_stats'
        end
      end

      resources :users, only: [:index, :show, :update, :destroy]
    end
  end
end
