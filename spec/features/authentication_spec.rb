require 'rails_helper'

describe 'Authentication' do
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:azure_activedirectory)

    stub_const('Hackney::Income::ReallyDangerousTenancyGateway', Hackney::Income::StubTenancyGatewayBuilder.build_stub)
    stub_const('Hackney::Income::TransactionsGateway', Hackney::Income::StubTransactionsGateway)
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth.delete(:azure_activedirectory)
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
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:azure_activedirectory]
  end

  def when_the_user_logs_in
    visit '/login'
    click_link href: '/auth/azureactivedirectory'
  end

  def then_they_should_be_taken_to_the_homepage_and_acknowledged
    expect(page.current_path).to eq('/')
    expect(page).to have_content('Example User')
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
