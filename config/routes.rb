Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/worktray', to: 'tenancies#index'

  get '/search', to: 'search_tenancies#show'

  get '/letters/new', to: 'letters#new'
  post '/letters/preview', to: 'letters#preview', as: :letter_preview
  post '/letters', to: 'letters#send_letter', as: :send_letter
  post '/letters/ajax_preview', to: 'letters#ajax_preview', as: :ajax_preview

  get '/documents/:id', to: 'documents#show', as: :document
  get '/documents', to: 'documents#index', as: :documents

  get '/tenancies/:id', to: 'tenancies#show', as: :tenancy
  get '/tenancies/:id/pause', to: 'tenancies#pause', as: :tenancy_pause
  patch '/tenancies/:id', to: 'tenancies#update'
  get '/tenancies/:id/sms', to: 'tenancies_sms#show', as: :tenancy_sms
  post '/tenancies/:id/sms', to: 'tenancies_sms#create', as: :create_tenancy_sms
  get '/tenancies/:id/email', to: 'tenancies_email#show', as: :tenancy_email
  post '/tenancies/:id/email', to: 'tenancies_email#create', as: :create_tenancy_email
  get '/tenancies/:id/transactions', to: 'tenancies_transactions#index', as: :tenancies_transactions
  get '/tenancies/:tenancy_ref/action_diary/new', to: 'action_diary_entry#show', as: :action_diary_entry
  post '/tenancies/:tenancy_ref/action_diary', to: 'action_diary_entry#create', as: :create_action_diary_entry
  get '/tenancies/:tenancy_ref/action_diary', to: 'action_diary_entry#index', as: :action_diary_entries

  get '/login', to: 'hackney_auth_session#show'
  get '/logout', to: 'hackney_auth_session#destroy'

  if Rails.env.development?
    get '/login/dev', to: 'dev_session#new'
  end

  root to: 'hackney_auth_session#show'
end
