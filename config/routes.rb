Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/worktray', to: 'tenancies#index', as: :worktray
  get '/worktray/v2/:service_area_type', to: 'actions#index', as: :worktray_v2

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

  get '/tenancies/:tenancy_ref/agreement/new/payment_type', to: 'agreements#payment_type', as: :agreement_payment_type
  post '/tenancies/:tenancy_ref/agreement/new/set_payment_type', to: 'agreements#set_payment_type', as: :set_agreement_payment_type
  get '/tenancies/:tenancy_ref/agreement/new', to: 'agreements#new', as: :new_agreement
  post '/tenancies/:tenancy_ref/agreement/create', to: 'agreements#create', as: :create_agreement
  get '/tenancies/:tenancy_ref/agreement/:id/show', to: 'agreements#show', as: :show_agreement
  get '/tenancies/:tenancy_ref/agreement/:id/cancel', to: 'agreements#confirm_cancellation', as: :confirm_agreement_cancellation
  post '/tenancies/:tenancy_ref/agreement/:id/cancel', to: 'agreements#cancel', as: :cancel_agreement
  get '/tenancies/:tenancy_ref/agreement/history', to: 'agreements#show_history', as: :show_agreements_history

  get '/tenancies/:tenancy_ref/court_cases/new', to: 'court_cases#new', as: :new_court_case
  post '/tenancies/:tenancy_ref/court_cases/create', to: 'court_cases#create', as: :create_court_case
  get '/tenancies/:tenancy_ref/court_date/:court_case_id/edit', to: 'court_cases#edit_court_date', as: :edit_court_date
  post '/tenancies/:tenancy_ref/court_date/:court_case_id/update', to: 'court_cases#update_court_date', as: :update_court_date
  get '/tenancies/:tenancy_ref/court_outcome/:court_case_id/edit', to: 'court_cases#edit_court_outcome', as: :edit_court_outcome
  post '/tenancies/:tenancy_ref/court_outcome/:court_case_id/update', to: 'court_cases#update_court_outcome', as: :update_court_outcome
  get '/tenancies/:tenancy_ref/court_outcome/:court_case_id/edit_terms', to: 'court_cases#edit_terms', as: :edit_court_outcome_terms
  post '/tenancies/:tenancy_ref/court_outcome/:court_case_id/update_terms', to: 'court_cases#update_terms', as: :update_court_outcome_terms
  get '/tenancies/:tenancy_ref/court_cases/:court_case_id/show', to: 'court_cases#show', as: :show_court_case
  get '/tenancies/:tenancy_ref/court_cases/show_success/:message', to: 'court_cases#show_success', as: :show_success_court_case
  get '/tenancies/:tenancy_ref/court_cases/history', to: 'court_cases#show_history', as: :show_court_cases_history

  get '/login', to: 'hackney_auth_session#new'
  get '/logout', to: 'hackney_auth_session#destroy'

  get '/login/dev', to: 'dev_session#new' if Rails.env.development?

  root to: 'hackney_auth_session#new'
end
