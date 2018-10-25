require 'rails_helper'

describe 'Viewing My Cases' do
  around { |example| with_mock_authentication { example.run } }
  before { stub_my_cases_response }

  scenario do
    given_i_am_logged_in
    when_i_visit_the_homepage
    then_i_should_see_a_phase_banner
    then_i_should_see_cases_assigned_to_me
  end

  scenario do
    given_i_am_logged_in
    when_i_visit_the_homepage
    when_i_click_on_the_paused_tab
    then_i_should_see_paused_cases
  end

  def given_i_am_logged_in
    visit '/auth/azureactivedirectory'
  end

  def when_i_visit_the_homepage
    visit '/'
  end

  def when_i_click_on_the_paused_tab
    click_link 'paused'
  end

  def then_i_should_see_paused_cases
    expect(page.body).to have_css('h2', text: 'Your paused cases', count: 1)
  end

  def then_i_should_see_cases_assigned_to_me
    expect(page.body).to have_css('h2', text: 'Your Worktray', count: 1)
    expect(page.body).to have_content('TEST/01')
    expect(page.body).to have_content('TEST/02')
  end

  def then_i_should_see_a_phase_banner
    expect(page.body).to have_css('.phase-tag', text: 'BETA', count: 1)
    expect(page.body).to have_css('.phase-banner span', text: 'This is a new service', count: 1)
  end

  def stub_my_cases_response
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)

    response_json = File.read(Rails.root.join('spec', 'fixtures', 'my_cases_response.json'))
    stub_request(:get, /my-cases/)
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json, headers: {})
  end
end
