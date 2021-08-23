Rails.application.routes.draw do
  resources :users
  resources :urls
  match '*path', to: 'redirect_controller#redirect_from_slug_to_url', via: :all
end
