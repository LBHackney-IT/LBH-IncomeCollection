def with_mock_authentication(attributes: {}, &block)
  authable_email = "#{Faker::StarTrek.character}@enterprise.fed.gov"
  OmniAuth.config.test_mode = true
  OmniAuth.config.add_mock(:azureactivedirectory)
  user_attributes = {
      'provider' => 'azureactivedirectory',
      'uid' => Faker::Number.number(12).to_s,
      'info' => {
      'name' => Faker::StarTrek.character,
      'email' => authable_email,
      'first_name' => Faker::StarTrek.specie,
      'last_name' => Faker::StarTrek.villain
    },
      'extra' => {
      'raw_info' => {
        'id_token' => "#{Faker::Number.number(6)}.123456ABC"
      }
    }
  }.merge(attributes.stringify_keys)
  OmniAuth.config.mock_auth[:azureactivedirectory] = OmniAuth::AuthHash.new(user_attributes)

  yield block

  OmniAuth.config.test_mode = false
  OmniAuth.config.mock_auth.delete(:azureactivedirectory)
  Rails.application.env_config.delete('omniauth.auth')
end
