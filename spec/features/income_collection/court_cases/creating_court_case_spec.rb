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
    and_i_click_on_create_court_case
    then_i_should_see_create_court_case_page

    when_i_fill_in_the_court_case_details
    and_i_click_on_create
    then_i_should_see_the_tenancy_page
    and_i_should_see_the_success_message
  end

  def when_i_visit_a_tenancy_with_arrears
    visit tenancy_path(id: '1234567/01')
  end

  def and_i_click_on_create_court_case
    click_link 'Create court case'
  end

  def then_i_should_see_create_court_case_page
    expect(page).to have_content('Create court case')
    expect(page).to have_content('Court case for: Alan Sugar')
    expect(page).to have_content('Date of court decision')
    expect(page).to have_content('Balance on court outcome date')
    expect(page).to have_content('Court outcome')
    expect(page).to have_content('Strike out date (optional)')
  end

  def when_i_fill_in_the_court_case_details
    fill_in 'date_of_court_decision', with: '21/07/2020'
    select('Stay of Execution', from: 'court_outcome')
    fill_in 'balance_on_court_outcome_date', with: '777.77'
    fill_in 'strike_out_date', with: '21/07/2026'
  end

  def and_i_click_on_create
    click_button 'Create'
  end

  def then_i_should_see_the_tenancy_page
    expect(page).to have_current_path(tenancy_path(id: '1234567/01'))
  end

  def and_i_should_see_the_success_message
    expect(page).to have_content('Successfully created a new court case')
  end

  def stub_create_court_case_response
    request_body_json = {
      court_decision_date: '21/07/2020',
      court_outcome: 'Stay of Execution',
      balance_at_outcome_date: '777.77',
      strike_out_date: '21/07/2026',
      created_by: 'Hackney User'
    }.to_json

    response_json = {
      "id": 12,
      "tenancyRef": '1234567/01',
      "courtDecisionDate": '21/07/2020',
      "courtOutcome": 'Stay of Execution',
      "balanceAtOutcomeDate": '777.77',
      "strikeOutDate": '21/07/2026',
      "createdBy": 'Hackney User',
      "createdAt": '2020-07-26'
    }.to_json

    stub_request(:post, 'https://example.com/income/api/v1/court_case/1234567%2F01/')
         .with(
           body: request_body_json,
           headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] }
         )
         .to_return(status: 200, body: response_json, headers: {})
  end
end
