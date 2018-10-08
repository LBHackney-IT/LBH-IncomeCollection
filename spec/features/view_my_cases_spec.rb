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

  def given_i_am_logged_in
    visit '/auth/azureactivedirectory'
  end

  def when_i_visit_the_homepage
    visit '/'
  end

  def then_i_should_see_cases_assigned_to_me
    expect(page.body).to have_content('TEST/01')
    expect(page.body).to have_content('TEST/02')
  end

  def then_i_should_see_a_phase_banner
    expect(page.body).to have_css('.phase-tag', text: 'ALPHA', count: 1)
    expect(page.body).to have_css('.phase-banner span', text: 'This is a new service', count: 1)
  end

  def stub_my_cases_response
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)

    response_json = File.read(Rails.root.join('spec', 'fixtures', 'my_cases_response.json'))
    stub_request(:get, "#{ENV['INCOME_COLLECTION_LIST_API_HOST']}/my-cases?number_per_page=20&page_number=1&user_id=1")
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json, headers: {})
  end
end
