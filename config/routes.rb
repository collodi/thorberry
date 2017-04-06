Rails.application.routes.draw do
  get 'status/index'

  root 'status#index'
end
