Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/worktray', to: 'tenancies#index', as: :worktray

  get '/search', to: 'search_tenancies#show'

  namespace :leasehold do
    get '/letters/new', to: 'letters#new'
    get '/letters/preview', to: redirect('/leasehold/letters/new')
    post '/letters/preview', to: 'letters#preview', as: :letter_preview
    post '/letters', to: 'letters#send_letter', as: :send_letter
    post '/letters/ajax_preview', to: 'letters#ajax_preview', as: :ajax_preview
  end
  namespace :income_collection do
    resources :letters, only: %i[index new create], param: :uuid do
      post :send_letter, on: :member
    end
    resources :admin, only: %i[index]
  end

  get '/documents/:id', to: 'documents#show', as: :document
  get '/documents', to: 'documents#index', as: :documents
  patch '/documents/:id/review_failure', to: 'documents#review_failure', as: :review_document_failure

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

  get '/feature-flags', to: 'feature_flags#index', as: :feature_flags_dashboard
  post '/feature-flags/:feature_name/activate', to: 'feature_flags#activate', as: :activate_feature_flag
  post '/feature-flags/:feature_name/deactivate', to: 'feature_flags#deactivate', as: :deactivate_feature_flag

  get '/login', to: 'hackney_auth_session#new'
  get '/logout', to: 'hackney_auth_session#destroy'

  get '/login/dev', to: 'dev_session#new' if Rails.env.development?

  root to: 'hackney_auth_session#new'
end
