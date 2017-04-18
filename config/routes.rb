Rails.application.routes.draw do
  get 'login/index'
  get 'login', to: 'login#index'

  post 'login', to: 'login#auth', as: :auth

  get 'logout', to: 'status#logout'

  get 'status/index'
  get 'status', to: 'status#index'

  get 'status/logs'
  get 'logs', to: 'status#logs'

  post 'logs', to: 'status#fetch_logs', as: :fetch_logs

  root 'login#index'
end
