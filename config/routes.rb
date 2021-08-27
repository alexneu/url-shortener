Rails.application.routes.draw do
  namespace :api do
    resources :urls
    resources :users, only: [:create]
    post '/login', to: 'auth#create'
  end
  
  match '*path', to: 'redirect#redirect_from_slug_to_url', via: :all
end
