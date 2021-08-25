Rails.application.routes.draw do
  resources :urls
  resources :users, only: [:create]
  post '/login', to: 'auth#create'
  
  match '*path', to: 'redirect#redirect_from_slug_to_url', via: :all
end
