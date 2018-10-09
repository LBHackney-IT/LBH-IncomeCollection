def with_mock_authentication(username: nil, &block)
  authable_email = "#{Faker::StarTrek.character}@enterprise.fed.gov"
  OmniAuth.config.test_mode = true
  OmniAuth.config.add_mock(:azureactivedirectory)
  OmniAuth.config.mock_auth[:azureactivedirectory] = OmniAuth::AuthHash.new(
    'provider' => 'azureactivedirectory',
    'uid' => Faker::Number.number(12).to_s,
    'info' => {
      'name' => username || Faker::StarTrek.character,
      'email' => authable_email,
      'first_name' => Faker::StarTrek.specie,
      'last_name' => Faker::StarTrek.villain
    },
    'extra' => {
      'raw_info' => {
        'id_token' => "#{Faker::Number.number(6)}.123456ABC"
      }
    }
  )

  ENV['IC_STAFF_GROUP'] = authable_email

  yield block

  OmniAuth.config.test_mode = false
  OmniAuth.config.mock_auth.delete(:azureactivedirectory)
  Rails.application.env_config.delete('omniauth.auth')

  ENV['IC_STAFF_GROUP'] = nil
end