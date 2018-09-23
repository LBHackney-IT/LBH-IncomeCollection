require 'rails_helper'

describe 'Authentication' do
  let(:provider_uid) { Faker::Number.number(12).to_s }
  let(:info_hash) do
    {
      'name' => Faker::StarTrek.character,
      'email' => "#{Faker::StarTrek.character}@enterprise.fed.gov",
      'first_name' => Faker::StarTrek.specie,
      'last_name' => Faker::StarTrek.villain
    }
  end
  let(:extra_hash) do
    {
      'raw_info' =>
      {
        'id_token' => "#{Faker::Number.number(6)}.123456ABC"
      }
    }
  end

  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:azureactivedirectory)
    OmniAuth.config.mock_auth[:azureactivedirectory] = OmniAuth::AuthHash.new(
      'provider' => 'azureactivedirectory',
      'uid' => provider_uid,
      'info' => info_hash,
      'extra' => extra_hash
    )

    ENV['IC_STAFF_GROUP'] = info_hash['email']

    stub_const('Hackney::Income::SqlTenancyCaseGateway', Hackney::Income::StubTenancyCaseGatewayBuilder.build_stub)
    stub_const('Hackney::Income::LessDangerousTenancyGateway', Hackney::Income::StubTenancyGatewayBuilder.build_stub)
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth.delete(:azureactivedirectory)
    Rails.application.env_config.delete('omniauth.auth')
  end

  example 'redirecting the user to the login page when not logged in' do
    when_the_user_is_not_logged_in
    then_they_should_be_prompted_to_log_in
  end

  example 'redirecting the user to the homepage after logging in' do
    given_the_user_has_a_valid_login
    when_the_user_logs_in
    then_they_should_be_taken_to_the_homepage_and_acknowledged
  end

  example 'redirecting the user to the login page after logging out' do
    given_the_user_is_logged_in
    when_the_user_logs_out
    then_they_should_be_informed_and_prompted_to_log_in_again
  end

  private

  def when_the_user_is_not_logged_in
    visit '/'
  end

  def then_they_should_be_prompted_to_log_in
    expect(page.current_path).to eq('/login')
    expect(page).to have_link(href: '/auth/azureactivedirectory')
  end

  def given_the_user_has_a_valid_login
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:azureactivedirectory]
  end

  def when_the_user_logs_in
    visit '/login'
    click_link href: '/auth/azureactivedirectory'
  end

  def then_they_should_be_taken_to_the_homepage_and_acknowledged
    expect(page.current_path).to eq('/')
    expect(page).to have_content(info_hash.fetch('name'))
  end

  def given_the_user_is_logged_in
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:azure_activedirectory]
    visit '/login'
    click_link href: '/auth/azureactivedirectory'
  end

  def when_the_user_logs_out
    click_link 'Sign out'
  end

  def then_they_should_be_informed_and_prompted_to_log_in_again
    expect(page.current_path).to eq('/login')
    expect(page).to have_content('You have been signed out')
  end
end
