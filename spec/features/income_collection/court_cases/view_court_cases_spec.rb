require 'rails_helper'

describe 'View agreements' do
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
  end

  after do
    FeatureFlag.deactivate('create_informal_agreements')
    FeatureFlag.deactivate('create_formal_agreements')
  end

  scenario 'viewing court cases' do
    given_i_am_logged_in
    and_there_are_existing_court_cases

    when_i_visit_the_tenancy_page
    then_i_should_see_the_court_case_details

    when_i_click_on_view_details
    then_i_should_see_the_court_case_details_page
    and_i_should_see_the_court_case_details

    when_i_visit_the_tenancy_page
    when_i_click_on_view_history
    then_i_should_see_the_court_case_history_page
    and_i_should_see_the_history_with_of_court_cases
  end

  def and_there_are_existing_court_cases
    court_cases_response = {
      courtCases:
      [
        {
        id: 14,
        tenancyRef: '1234567/01',
        courtDate: '24/07/2020',
        courtOutcome: 'Suspension on terms',
        balanceOnCourtOutcomeDate: '1800',
        strikeOutDate: '24/07/2021',
        terms: nil,
        disrepairCounterClaim: nil
      },
        {
          id: 15,
          tenancyRef: '1234567/01',
          courtDate: '26/09/2020',
          courtOutcome: 'Adjourned generally with permission to restore',
          balanceOnCourtOutcomeDate: '1700',
          strikeOutDate: '10/07/2025',
          terms: false,
          disrepairCounterClaim: true
        }
    ]
    }.to_json

    stub_request(:get, 'https://example.com/income/api/v1/court_cases/1234567%2F01/')
      .to_return(status: 200, body: court_cases_response)
  end

  def when_i_visit_the_tenancy_page
    visit tenancy_path(id: '1234567/01')
  end

  def then_i_should_see_the_court_case_details
    expect(page).to have_content('Court date')
    expect(page).to have_content('September 26th, 2020')
    expect(page).to have_content('Court outcome:')
    expect(page).to have_content('Adjourned generally with permission to restore')
    expect(page).to have_content('Strike out date:')
    expect(page).to have_content('July 10th, 2025')
    expect(page).to have_content('Balance on court date:')
    expect(page).to have_content('£1,700')
    expect(page).to have_content('Terms: No')
    expect(page).to have_content('Disrepair counter claim: Yes')
  end

  def when_i_click_on_view_details
    click_link 'View details'
  end

  def then_i_should_see_the_court_case_details_page
    expect(page).to have_content('Alan Sugar')
  end

  def and_i_should_see_the_court_case_details
    then_i_should_see_the_court_case_details
  end

  def when_i_click_on_view_history
    click_link 'View history'
  end

  def then_i_should_see_the_court_case_history_page
    expect(page).to have_content('History of court cases')
    expect(page).to have_content('All court cases associated with Alan Sugar')
  end

  def and_i_should_see_the_history_with_of_court_cases
    court_cases_history_table = find('table')

    expect(court_cases_history_table).to have_content('Status')

    expect(court_cases_history_table).to have_content('Court date')
    expect(court_cases_history_table).to have_content('July 24th, 2020')
    expect(court_cases_history_table).to have_content('September 26th, 2020')

    expect(court_cases_history_table).to have_content('Strike out date')
    expect(court_cases_history_table).to have_content('July 10th, 2025')

    expect(court_cases_history_table).to have_content('Balance')
    expect(court_cases_history_table).to have_content('£1,700')
    expect(court_cases_history_table).to have_content('£1,800')

    expect(court_cases_history_table).to have_content('Court outcome')
    expect(court_cases_history_table).to have_content('Adjourned generally with permission to restore')
    expect(court_cases_history_table).to have_content('Suspension on terms')

    expect(court_cases_history_table).to have_link('View details').twice
  end
end
