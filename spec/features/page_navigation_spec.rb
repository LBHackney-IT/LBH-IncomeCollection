require 'rails_helper'

describe 'Page navigation' do
  before do
    create_jwt_token

    stub_tenancy_api_tenancy(tenancy_ref: 'TEST%2F01')
    stub_tenancy_api_payments(tenancy_ref: 'TEST%2F01')
    stub_tenancy_api_actions(tenancy_ref: 'TEST%2F01')
    stub_tenancy_api_contacts(tenancy_ref: 'TEST%2F01', response: tenancy_api_contacts_response)

    stub_income_api_my_cases
    stub_income_api_show_tenancy(tenancy_ref: 'TEST%2F01')
    stub_view_agreements_response(tenancy_ref: 'TEST%2F01')
    stub_view_court_cases_responses(tenancy_ref: 'TEST%2F01')

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

  def tenancy_api_contacts_response
    {
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
  end

  def stub_income_api_my_cases
    response_json = File.read(Rails.root.join('spec', 'examples', 'my_cases_response.json'))

    stub_request(:get, 'https://example.com/income/api/v1/cases')
      .with(query: hash_including(
        is_paused: 'false',
        number_per_page: '20',
        page_number: '1'
      ))
      .with(headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_users_gateway
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)
  end
end
