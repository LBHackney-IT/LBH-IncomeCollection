Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'tenancies#index'
  get '/search', to: 'search_tenancies#show'

  get '/tenancies/:id', to: 'tenancies#show', as: :tenancy
  post '/tenancies/:id', to: 'tenancies#pause', as: :pause
  get '/tenancies/:id/sms', to: 'tenancies_sms#show', as: :tenancy_sms
  post '/tenancies/:id/sms', to: 'tenancies_sms#create', as: :create_tenancy_sms
  get '/tenancies/:id/email', to: 'tenancies_email#show', as: :tenancy_email
  post '/tenancies/:id/email', to: 'tenancies_email#create', as: :create_tenancy_email
  get '/tenancies/:id/transactions', to: 'tenancies_transactions#index', as: :tenancies_transactions
  get '/tenancies/:id/action_diary/new', to: 'action_diary_entry#show', as: :action_diary_entry
  post '/tenancies/:id/action_diary', to: 'action_diary_entry#create', as: :create_action_diary_entry
  get '/tenancies/:id/action_diary', to: 'action_diary_entry#index', as: :action_diary_entries

  get '/login', to: 'sessions#new', as: :login
  get '/logout', to: 'sessions#destroy', as: :logout
  match '/auth/:provider/callback', to: 'sessions#create', via: %i[get post]
  match '/auth/:provider/failure', to: 'sessions#failure', via: %i[get post]
end
