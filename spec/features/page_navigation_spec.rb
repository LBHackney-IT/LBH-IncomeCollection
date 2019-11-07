require 'rails_helper'

describe 'Page navigation' do
  before do
    create_jwt_token

    stub_income_api_tenancy
    stub_income_api_payments
    stub_income_api_actions
    stub_income_api_contacts

    stub_tenancy_api_my_cases
    stub_tenancy_api_show_tenancy

    stub_users_gateway
  end

  scenario do
    given_i_am_logged_in
    when_i_am_on_the_root_path_on_page_one
    when_i_am_on_the_root_path_i_can_see_the_next_page_link
    i_then_click_a_tenancy
    i_then_go_back_to_the_root_path
    then_i_should_be_on_page_one
  end

  def when_i_am_on_the_root_path_on_page_one
    visit '/worktray?page=1'
  end

  def when_i_am_on_the_root_path_i_can_see_the_next_page_link
    expect(page).to have_content('Next ›')
  end

  def i_then_click_a_tenancy
    click_on 'TEST/01'
  end

  def i_then_go_back_to_the_root_path
    click_on 'Return back to your worktray'
  end

  def then_i_should_be_on_page_one
    expect(page).to have_current_path(worktray_path(page: '1'))
  end

  def stub_income_api_tenancy
    response_json = File.read(Rails.root.join('spec', 'examples', 'single_case_response.json'))

    stub_request(:get, 'https://example.com/tenancy/api/v1/tenancies/TEST%2F01')
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_income_api_payments
    response_json = { 'payment_transactions': [] }.to_json

    stub_request(:get, 'https://example.com/tenancy/api/v1/tenancies/TEST%2F01/payments')
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_income_api_contacts
    response_json = {
      data: {
        contacts: [{
          post_code: 'E8 1DY',
          responsible: true,
          address_line1: 'Primary Street',
          title: 'Mr',
          first_name: 'Alan',
          last_name: 'Sugar',
          email_address: 'alan.sugar@example.com'
        }]
      }
    }.to_json

    stub_request(:get, 'https://example.com/tenancy/api/v1/tenancies/TEST%2F01/contacts')
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_tenancy_api_my_cases
    response_json = File.read(Rails.root.join('spec', 'examples', 'my_cases_response.json'))

    stub_request(:get, 'https://example.com/income/api/v1/cases')
      .with(query: hash_including(
        is_paused: 'false',
        number_per_page: '20',
        page_number: '1'
      ))
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_income_api_actions
    response_json = { arrears_action_diary_events: [] }.to_json

    stub_request(:get, 'https://example.com/tenancy/api/v1/tenancies/TEST%2F01/actions')
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_tenancy_api_show_tenancy
    response_json = File.read(Rails.root.join('spec', 'examples', 'single_case_priority_response.json'))

    stub_request(:get, 'https://example.com/income/api/v1/tenancies/TEST%2F01')
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_users_gateway
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)
  end
end
