require 'rails_helper'

describe 'Viewing A Single Case' do
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
    then_i_should_see_a_pause_button
    then_i_should_see_case_meta_data
    then_i_should_see_case_account_balance
    then_i_should_see_tenant_details
    then_i_should_see_contact_details
    then_i_should_see_contact_buttons
    then_i_should_see_balance_graph
    then_i_should_see_agreements_table
    then_i_should_see_transaction_history
    then_i_should_see_action_diary_table
    then_i_should_see_action_diary_buttons
  end

  def given_i_am_logged_in
    visit '/auth/azureactivedirectory'
  end

  def when_i_visit_a_tenancy
    visit tenancy_path(id: '1234567/01')
  end

  def then_i_should_see_case_meta_data
    expect(page.body).to have_css('li', text: 'Reference number: 1234567/01', count: 1)
    expect(page.body).to have_css('li', text: 'Payment reference: 1010101010', count: 1)
    expect(page.body).to have_css('li', text: 'Start date: August 30th, 2014', count: 1)
    expect(page.body).to have_css('li', text: 'Assigned to: Billy Bob (Credit Controller)', count: 1)
  end

  def then_i_should_see_case_account_balance
    expect(page.body).to have_css('h2', text: 'Account balance', count: 1)
    expect(page.body).to have_css('.data-item', text: '£103.57', count: 1)
    expect(page.body).to have_css('.data-item', text: 'in arrears', count: 1)
  end

  def then_i_should_see_balance_graph
    expect(page.body).to have_css('h2', text: 'Balance over time', count: 1)
    expect(page.body).to have_css('canvas#balance_chart', count: 1)
    # page.execute_script('draw_graph()')
    # expect(page.body).to have_script('var transactions = []', count: 1)
  end

  def then_i_should_see_tenant_details
    expect(page.body).to have_css('h2', text: 'Personal details', count: 1)
    expect(page.body).to have_css('h3', text: 'Tenancy address', count: 1)
    expect(page.body).to have_css('li', text: '1 Hillman street', count: 1)
    expect(page.body).to have_css('li', text: 'E8 1DY', count: 2)
    expect(page.body).to have_css('h3', text: 'Primary Tenant', count: 1)
    expect(page.body).to have_css('li', text: 'HILLMAN STREET', count: 1)
    expect(page.body).to have_css('li', text: 'HACKNEY', count: 1)
  end

  def then_i_should_see_agreements_table
    expect(page.body).to have_css('h2', text: 'Arrears Agreements', count: 1)
    expect(page.body).to have_css('th', text: 'Start Date', count: 1)
    expect(page.body).to have_css('th', text: 'Status', count: 1)
    expect(page.body).to have_css('th', text: 'Breached?', count: 1)
    expect(page.body).to have_css('th', text: 'Frequency', count: 1)
    expect(page.body).to have_css('th', text: 'Clear by', count: 1)
    expect(page.body).to have_css('th', text: 'Value', count: 1)
    expect(page.body).to have_css('.agreement_row td', text: 'March 30th, 2015', count: 1)
    expect(page.body).to have_css('.agreement_row td', text: 'Suspended', count: 1)
    expect(page.body).to have_css('.agreement_row td', text: 'Yes', count: 1)
    expect(page.body).to have_css('.agreement_row td', text: 'Weekly', count: 1)
    expect(page.body).to have_css('.agreement_row td', text: 'May 24th, 2025', count: 1)
    expect(page.body).to have_css('.agreement_row td', text: '£3.70', count: 1)
  end

  def then_i_should_see_action_diary_table
    expect(page.body).to have_css('h2', text: 'Action Diary', count: 1)
    expect(page.body).to have_css('th', text: 'Description', count: 1)
    expect(page.body).to have_css('th', text: 'Type', count: 1)
    expect(page.body).to have_css('th', text: 'Code', count: 1)
    expect(page.body).to have_css('th', text: 'User', count: 1)
    expect(page.body).to have_css('td', text: 'Tnt\'s support worker called with Mr Sugar present to ask how much rent they needed to pay advised that HB were paying the full rent', count: 1)
    expect(page.body).to have_css('td', text: 'Incoming telephone call', count: 1)
    expect(page.body).to have_css('td', text: 'INC', count: 1)
    expect(page.body).to have_css('td', text: 'July 4th, 2016 12:29', count: 1)
    expect(page.body).to have_css('td', text: 'Thomas Mcinnes', count: 1)
  end

  def then_i_should_see_action_diary_buttons
    expect(page.body).to have_css('.link--forward', text: 'View the full arrears action diary', count: 1)
    expect(page).to have_link(href: '/tenancies/1234567%2F01/action_diary')
    expect(page.body).to have_css('.button', text: 'Add an action', count: 1)
    expect(page).to have_link(href: '/tenancies/1234567%2F01/action_diary/new')
  end

  def then_i_should_see_transaction_history
    expect(page.body).to have_css('h2', text: 'Payment history', count: 1)
    expect(page.body).to have_css('.column-full', text: 'There have been no transactions in the last four weeks.', count: 1)
    expect(page.body).to have_css('.link--forward', text: 'View the full payment history', count: 1)
    expect(page).to have_link(href: '/tenancies/1234567%2F01/transactions')
  end

  def then_i_should_see_contact_details
    expect(page.body).to have_css('h3', text: 'Contact details', count: 1)
    expect(page.body).to have_css('.contact-details-list__responsible', text: 'Responsible Tenant', count: 1)
    expect(page.body).to have_css('.contact-details-list li', text: 'Title: Mr', count: 1)
    expect(page.body).to have_css('.contact-details-list li', text: 'First Name: Alan', count: 1)
    expect(page.body).to have_css('.contact-details-list li', text: 'Last Name: Sugar', count: 2)
    expect(page.body).to have_css('.contact-details-list li', text: 'Phone One: 07123456789', count: 1)
    expect(page.body).to have_css('.contact-details-list li', text: 'Phone Two: 07070707070', count: 1)
    expect(page.body).to have_css('.contact-details-list li', text: 'Phone Three: 07987654321', count: 1)
    expect(page.body).to have_css('.contact-details-list li', text: 'E-Mail: sugar_ring@dougnut.com', count: 1)
    expect(page.body).to have_css('.contact-details-list li', text: 'Title: Ms', count: 1)
    expect(page.body).to have_css('.contact-details-list li', text: 'Phone One: 01010101010', count: 1)
    expect(page.body).to have_css('.contact-details-list li', text: 'Phone Two: 02020202020', count: 1)
    expect(page.body).to have_css('.contact-details-list li', text: 'Phone Three: 03030303030', count: 1)
  end

  def then_i_should_see_contact_buttons
    expect(page.body).to have_css('.button', text: 'Send SMS', count: 1)
    expect(page).to have_link(href: '/tenancies/1234567%2F01/sms?tenancy_ref=1234567%2F01')
    expect(page.body).to have_css('.button', text: 'Send Email', count: 1)
    expect(page).to have_link(href: '/tenancies/1234567%2F01/email?tenancy_ref=1234567%2F01')
  end

  def then_i_should_see_a_phase_banner
    expect(page.body).to have_css('.phase-tag', text: 'BETA', count: 1)
    expect(page.body).to have_css('.phase-banner span', text: 'This is a new service - your feedback will help us to improve it.', count: 1)
  end

  def then_i_should_see_a_search_button
    expect(page.body).to have_css('.button--dark-grey', text: 'Search', count: 1)
    expect(page).to have_link(href: '/search')
  end

  def then_i_should_see_a_pause_button
    expect(page.body).to have_css('.button', text: 'Pause', count: 1)
    expect(page).to have_link(href: '/tenancies/1234567%2F01/pause')
  end

  def stub_my_cases_response
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)

    response_json = File.read(Rails.root.join('spec', 'examples', 'my_cases_response.json'))
    stub_request(:get, /my-cases\?is_paused=false&number_per_page=20&page_number=1&user_id=/)
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_view_case_response
    response_json = JSON.parse(File.read(Rails.root.join('spec', 'examples', 'single_case_priority_response.json')))
    allow_any_instance_of(Hackney::Income::TenancyGateway).to receive(:get_case_priority).and_return(response_json.deep_symbolize_keys)

    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)

    response_json = File.read(Rails.root.join('spec', 'examples', 'single_case_response.json'))
    stub_request(:get, %r{/api\/v1\/tenancies\/1234567/})
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end
end
