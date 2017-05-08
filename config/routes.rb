Rails.application.routes.draw do
  # devise_for :users, :controllers => {:registrations => "users/registrations", :passwords => "users/passwords"}
  # devise_for :users
  devise_for :users, :controllers => { registrations: 'registrations' }
  root to: "home#index"
  get '/history', to: 'home#history'
  get '/log',     to: 'home#log'
  resources :games
end
