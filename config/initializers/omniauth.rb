OmniAuth.config.logger = Rails.logger

module OmniAuthWithExceptionHandling
  def callback_phase
    super
  rescue OmniAuth::Strategies::AzureActiveDirectory::OAuthError
    redirect '/auth/failure'
  end
end

OmniAuth::Strategies::AzureActiveDirectory.prepend OmniAuthWithExceptionHandling

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :azure_activedirectory, ENV['AAD_CLIENT_ID'], ENV['AAD_TENANT']
end
