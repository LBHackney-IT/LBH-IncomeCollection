module AuthHelper
  def auth_provider_path
    if Rails.env.development? && ENV['AUTH_NO_AZURE_AD'] == true
      '/auth/developer'
    else
      '/auth/azureactivedirectory'
    end
  end
end