Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/', to: 'tenancies#index', as: :tenancies
  get '/tenancies/:id', to: 'tenancies#show', as: :tenancy
end
