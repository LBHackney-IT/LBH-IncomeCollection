require 'rails_helper'

describe 'Create court case' do
  before do
    FeatureFlag.activate('create_informal_agreements')
    FeatureFlag.activate('create_formal_agreements')

    create_jwt_token

    stub_my_cases_response
    stub_income_api_show_tenancy
    stub_tenancy_api_payments
    stub_tenancy_api_contacts
    stub_tenancy_api_actions
    stub_tenancy_api_tenancy
    stub_view_agreements_response
    stub_create_court_case_response
  end

  after do
    FeatureFlag.deactivate('create_informal_agreements')
  end

  scenario 'creating a new court case' do
    given_i_am_logged_in

    when_i_visit_a_tenancy_with_arrears
    then_i_should_see_the_court_case_section
    and_i_click_on_add_court_date

    then_i_should_see_add_court_date_page
    when_i_fill_in_the_court_date
    and_i_click_on_add

    then_i_should_see_the_tenancy_page
    and_i_should_see_the_success_message
  end

  def when_i_visit_a_tenancy_with_arrears
    visit tenancy_path(id: '1234567/01')
  end

  def then_i_should_see_the_court_case_section
    expect(page).to have_content('Court case')
    expect(page).to have_content('No valid court case at this time')
    expect(page).to have_link('Add court date')
  end

  def and_i_click_on_add_court_date
    click_link 'Add court date'
  end

  def then_i_should_see_add_court_date_page
    expect(page).to have_content('Add court date')
    expect(page).to have_content('Court date')
    expect(page).to have_button('Add')
  end

  def when_i_fill_in_the_court_date
    fill_in 'court_date', with: '21/07/2020'
  end

  def and_i_click_on_add
    click_button 'Add'
  end

  def then_i_should_see_the_tenancy_page
    expect(page).to have_current_path(tenancy_path(id: '1234567/01'))
  end

  def and_i_should_see_the_success_message
    expect(page).to have_content('Successfully created a new court case')
  end

  def stub_tenancy_with_arrears
    response_json = File.read(Rails.root.join('spec', 'examples', 'single_case_priority_response.json'))

    stub_request(:get, 'https://example.com/income/api/v1/tenancies/1234567%2F01')
      .with(headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_my_cases_response
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)

    response_json = File.read(Rails.root.join('spec', 'examples', 'my_cases_response.json'))
    stub_request(:get, /cases\?full_patch=false&is_paused=false&number_per_page=20&page_number=1&upcoming_court_dates=false&upcoming_evictions=false/)
      .with(headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_create_court_case_response
    request_body_json = {
      court_date: '21/07/2020',
      court_outcome: nil,
      balance_on_court_outcome_date: nil,
      strike_out_date: nil,
      terms: nil,
      disrepair_counter_claim: nil
    }.to_json

    response_json = {
      "id": 12,
      "tenancyRef": '1234567/01',
      "courtDate": '21/07/2020',
      "courtOutcome": nil,
      "balanceOnCourtOutcomeDate": nil,
      "strikeOutDate": nil,
      "terms": nil,
      "disrepairCounterClaim": nil
    }.to_json

    stub_request(:post, 'https://example.com/income/api/v1/court_case/1234567%2F01/')
         .with(
           body: request_body_json,
           headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] }
         )
         .to_return(status: 200, body: response_json, headers: {})
  end
end
