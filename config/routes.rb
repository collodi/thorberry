Rails.application.routes.draw do
  get 'status/index'
  get 'status/log'

  root 'status#index'
end
