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
    stub_view_court_cases_response
    stub_update_court_case_response
  end

  after do
    FeatureFlag.deactivate('create_informal_agreements')
    FeatureFlag.deactivate('create_formal_agreements')
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
    and_i_should_see_the_view_history_link
    and_i_should_see_the_court_date

    when_i_click_on_edit_court_date
    then_i_should_see_edit_court_date_page
    and_i_should_see_the_current_curt_date
    when_i_fill_in_the_new_court_date
    and_i_click_on_save

    then_i_should_see_the_tenancy_page
    and_i_should_see_the_update_success_message
    and_i_should_see_the_updated_court_date
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

  def and_i_should_see_the_view_history_link
    expect(page).to have_content('View history')
  end

  def and_i_should_see_the_court_date
    expect(page).to have_content('Court date: July 21st, 2020')
  end

  def when_i_click_on_edit_court_date
    click_link 'Edit court date'
  end

  def then_i_should_see_edit_court_date_page
    expect(page).to have_content('Edit court date')
    expect(page).to have_content('Court date')
    expect(page).to have_button('Save')
  end

  def and_i_should_see_the_current_curt_date
    expect(find_field('court_date').value).to eq('2020-07-21')
  end

  def when_i_fill_in_the_new_court_date
    fill_in 'court_date', with: '23/07/2020'
  end

  def and_i_click_on_save
    click_button 'Save'
  end

  def and_i_should_see_the_update_success_message
    expect(page).to have_content('Successfully updated the court case')
  end

  def and_i_should_see_the_updated_court_date
    expect(page).to have_content('Court date: July 23rd, 2020')
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
      id: 12,
      tenancyRef: '1234567/01',
      courtDate: '21/07/2020',
      courtOutcome: nil,
      balanceOnCourtOutcomeDate: nil,
      strikeOutDate: nil,
      terms: nil,
      disrepairCounterClaim: nil
    }.to_json

    stub_request(:post, 'https://example.com/income/api/v1/court_case/1234567%2F01/')
         .with(
           body: request_body_json,
           headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] }
         )
         .to_return(status: 200, body: response_json, headers: {})
  end

  def stub_update_court_case_response
    request_body_json = {
      court_date: '23/07/2020',
      court_outcome: nil,
      balance_on_court_outcome_date: nil,
      strike_out_date: nil,
      terms: nil,
      disrepair_counter_claim: nil
    }.to_json

    stub_request(:patch, 'https://example.com/income/api/v1/court_case/12/update')
         .with(
           body: request_body_json,
           headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] }
         )
         .to_return(status: 200, headers: {})
  end

  def stub_view_court_cases_response
    no_court_cases_response_json = {
      courtCases: []
 }.to_json

    one_court_case_response_json = {
      courtCases:
        [{
          id: 12,
          tenancyRef: '1234567/01',
          courtDate: '21/07/2020',
          courtOutcome: nil,
          balanceOnCourtOutcomeDate: nil,
          strikeOutDate: nil,
          terms: nil,
          disrepairCounterClaim: nil
        }]
}.to_json

    updated_court_case_response_json = {
      courtCases:
        [{
          id: 12,
          tenancyRef: '1234567/01',
          courtDate: '23/07/2020',
          courtOutcome: nil,
          balanceOnCourtOutcomeDate: nil,
          strikeOutDate: nil,
          terms: nil,
          disrepairCounterClaim: nil
        }]
    }.to_json

    stub_request(:get, 'https://example.com/income/api/v1/court_cases/1234567%2F01/')
      .to_return({ status: 200, body: no_court_cases_response_json },
                 { status: 200, body: one_court_case_response_json },
                 { status: 200, body: one_court_case_response_json },
                 status: 200, body: updated_court_case_response_json)
  end
end
