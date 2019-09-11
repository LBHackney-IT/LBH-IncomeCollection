module AuthHelper
  def auth_provider_path
    return '/auth/developer' if Rails.env.development? && ENV.fetch('AUTH_NO_AZURE_AD', false).to_s == 'true'
    '/auth/azureactivedirectory'
  end
end
