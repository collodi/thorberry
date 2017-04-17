Rails.application.routes.draw do
  get 'status/index'
  get 'status', to: 'status#index'

  get 'status/logs'
  get 'logs', to: 'status#logs'

  post 'logs', to: 'status#fetch_logs', as: :fetch_logs

  root 'status#index'
end
