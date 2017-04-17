Rails.application.routes.draw do
  get 'status/index'
  get 'status', to: 'status#index'

  get 'status/logs'
  get 'logs', to: 'status#logs'

  root 'status#index'
end
