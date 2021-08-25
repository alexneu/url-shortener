Rails.application.routes.draw do
  resources :users, only: [:create]
  post '/login', to: 'auth#create'
  get '/profile', to: 'users#profile'
  
  resources :urls
  match '*path', to: 'redirect#redirect_from_slug_to_url', via: :all
end
