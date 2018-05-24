Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'tenancies#index'
  get '/tenancies/:id', to: 'tenancies#show', as: :tenancy
  get '/tenancies/:id/sms', to: 'tenancies_sms#show', as: :tenancy_sms

  get '/login', to: 'sessions#new', as: :login
  get '/logout', to: 'sessions#destroy', as: :logout
  match '/auth/:provider/callback', to: 'sessions#create', via: %i(get post)
end
