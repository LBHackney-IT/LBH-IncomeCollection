module AuthHelper
  def auth_provider_path
    return '/auth/developer' if Rails.env.development? && ENV['AUTH_NO_AZURE_AD'] == 'true'
    '/auth/azureactivedirectory'
  end
end
