require 'rails_helper'

describe 'Viewing Transaction History' do
  around { |example| with_mock_authentication { example.run } }

  before do
    stub_my_cases_response
    stub_view_case_response
  end

  scenario do
    given_i_am_logged_in
    when_i_visit_a_tenancy
    then_i_should_see_a_phase_banner
    then_i_should_see_a_search_button
    then_i_should_see_transaction_history
  end

  def given_i_am_logged_in
    visit '/auth/azureactivedirectory'
  end

  def when_i_visit_a_tenancy
    visit tenancies_transactions_path(id: '1234567/01')
  end

  def then_i_should_see_case_meta_data
    expect(page.body).to have_css('li', text: 'Reference number: 1234567/01', count: 1)
    expect(page.body).to have_css('li', text: 'Payment reference: 1010101010', count: 1)
    expect(page.body).to have_css('li', text: 'Start date: August 30th, 2014', count: 1)
  end

  def then_i_should_see_transaction_history
    expect(page.body).to have_css('h2', text: 'Payment history', count: 1)
    expect(page.body).to have_css('th', text: 'Date', count: 1)
    expect(page.body).to have_css('th', text: 'Transaction', count: 1)
    expect(page.body).to have_css('th', text: 'Incoming', count: 1)
    expect(page.body).to have_css('th', text: 'Outgoing', count: 1)
    expect(page.body).to have_css('th', text: 'Balance', count: 1)
    expect(page.body).to have_css('.numeric.negative', text: '£0.00', count: 1)  # incoming
    expect(page.body).to have_css('.numeric.positive', text: '£93.38', count: 1) # outgoing
    expect(page.body).to have_css('.numeric', text: '£103.57', count: 1)
  end

  def then_i_should_see_a_phase_banner
    expect(page.body).to have_css('.phase-tag', text: 'BETA', count: 1)
    expect(page.body).to have_css('.phase-banner span', text: 'This is a new service - your feedback will help us to improve it.', count: 1)
  end

  def then_i_should_see_a_search_button
    expect(page.body).to have_css('.button--dark-grey', text: 'Search', count: 1)
    expect(page).to have_link(href: '/search')
  end

  def stub_my_cases_response
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)

    response_json = File.read(Rails.root.join('spec', 'examples', 'my_cases_response.json'))
    stub_request(:get, /my-cases\?is_paused=false&number_per_page=20&page_number=1&user_id=/)
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_view_case_response
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)

    response_json = File.read(Rails.root.join('spec', 'examples', 'single_case_response.json'))
    stub_request(:get, %r{/api\/v1\/tenancies\/1234567/})
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end
end
