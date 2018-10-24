OmniAuth.config.logger = Rails.logger
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :azure_activedirectory, ENV['AAD_CLIENT_ID'], ENV['AAD_TENANT']
end
