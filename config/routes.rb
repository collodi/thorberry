Rails.application.routes.draw do
  get 'login', to: 'login#index'
  post 'login', to: 'login#auth', as: :auth

  get 'logout', to: 'status#logout'

  get 'status', to: 'status#index'

  get 'logs', to: 'status#logs'
  post 'logs', to: 'status#fetch_logs', as: :fetch_logs

  get 'pins', to: 'status#pins'
  post 'pins', to: 'status#set_pins', as: :set_pins

  root 'login#index'
end
