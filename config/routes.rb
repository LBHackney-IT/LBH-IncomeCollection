Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'tenancies#index'
  get '/tenancies/:id', to: 'tenancies#show', as: :tenancy
  get '/tenancies/:id/sms', to: 'tenancies_sms#show', as: :tenancy_sms
  post '/tenancies/:id/sms', to: 'tenancies_sms#create', as: :create_tenancy_sms
  get '/tenancies/:id/email', to: 'tenancies_email#show', as: :tenancy_email
  post '/tenancies/:id/email', to: 'tenancies_email#create', as: :create_tenancy_email
  get '/tenancies/:id/action_diary', to: 'action_diary_entry#show', as: :action_diary_entry
  post '/tenancies/:id/action_diary', to: 'action_diary_entry#create', as: :create_action_diary_entry

  get '/login', to: 'sessions#new', as: :login
  get '/logout', to: 'sessions#destroy', as: :logout
  match '/auth/:provider/callback', to: 'sessions#create', via: %i[get post]
end
