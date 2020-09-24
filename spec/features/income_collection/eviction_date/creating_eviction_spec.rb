require 'rails_helper'

describe 'Create court case' do
  before do
    create_jwt_token

    stub_my_cases_response
    stub_income_api_show_tenancy
    stub_tenancy_api_payments
    stub_tenancy_api_contacts
    stub_tenancy_api_actions
    stub_tenancy_api_tenancy
    stub_view_agreements_response
    stub_create_eviction_response
    stub_view_court_cases_responses
  end

  scenario 'creating a new court case' do
    given_i_am_logged_in

    when_i_visit_a_tenancy_with_arrears
    then_i_should_see_the_eviction_section
    and_i_click_on_add_eviction_date

    then_i_should_see_eviction_date_page
    when_i_fill_in_the_eviction_date
    and_i_click_on_add

    then_i_should_see_the_tenancy_page
    and_i_should_see_the_success_message
  end

  def when_i_visit_a_tenancy_with_arrears
    visit tenancy_path(id: '1234567/01')
  end

  def then_i_should_see_the_eviction_section
    expect(page).to have_content('Add eviction date')
  end

  def and_i_click_on_add_eviction_date
    click_link 'Add eviction date'
  end

  def then_i_should_see_eviction_date_page
    expect(page).to have_content('Add eviction date')
    expect(page).to have_content('Eviction date')
    expect(page).to have_button('Add')
  end

  def when_i_fill_in_the_eviction_date
    fill_in 'eviction_date', with: '21/07/3000'
  end

  def and_i_click_on_add
    click_button 'Add'
  end

  def then_i_should_see_the_tenancy_page
    expect(page).to have_current_path(tenancy_path(id: '1234567/01'))
  end

  def and_i_should_see_the_success_message
    expect(page).to have_content('Successfully created a new eviction date')
  end

  def stub_my_cases_response
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)

    response_json = File.read(Rails.root.join('spec', 'examples', 'my_cases_response.json'))
    stub_request(:get, /cases\?full_patch=false&is_paused=false&number_per_page=20&page_number=1&upcoming_court_dates=false&upcoming_evictions=false/)
      .with(headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_create_eviction_response
    request_body_json = {
      date: '21/07/3000'
    }.to_json

    response_json = {
      id: 12,
      date: '21/07/3000'
    }.to_json

    stub_request(:post, 'https://example.com/income/api/v1/eviction/1234567%2F01/')
         .with(
           body: request_body_json,
           headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] }
         )
         .to_return(status: 200, body: response_json, headers: {})
  end
end
