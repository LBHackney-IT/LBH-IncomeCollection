require 'rails_helper'

describe 'Create Formal agreement' do
  before do
    create_jwt_token

    stub_my_cases_response
    stub_income_api_show_tenancy
    stub_tenancy_api_payments
    stub_tenancy_api_contacts
    stub_tenancy_api_actions
    stub_tenancy_api_tenancy
    stub_create_agreement_response
    stub_view_agreements_response
    stub_cancel_agreement_response
    stub_view_court_cases_responses(responses: view_court_cases_responses)
    stub_create_court_case_response
    stub_update_court_outcome_response
  end

  scenario 'creating a new Formal agreement' do
    given_i_am_logged_in

    when_i_visit_a_tenancy_with_arrears
    and_i_create_a_court_case_with_an_outcome_with_terms
    then_i_should_see_create_agreement_page
    then_i_should_see_the_starting_balance_field

    when_i_fill_in_the_agreement_details
    and_i_click_on_create
    then_i_should_see_the_agreement_page
    and_i_can_not_see_the_button_to_send_agreement_confirmation_letter

    when_i_click_link_to_go_back_to_case_profile
    then_i_should_see_the_tenancy_page
    and_i_should_see_the_new_agreement
    and_i_should_see_the_agreement_status
  end

  def when_i_visit_a_tenancy_with_arrears
    visit tenancy_path(id: '1234567/01')
  end

  def and_i_create_a_court_case_with_an_outcome_with_terms
    click_link 'Add court date'
    fill_in 'court_date', with: '21/07/2020'
    click_button 'Add'

    click_link 'Add court outcome'
    choose('court_outcome_ADT')
    fill_in 'balance_on_court_outcome_date', with: '1000'
    click_button 'Add outcome'

    choose('terms_Yes')
    choose('disrepair_counter_claim_No')
    click_button 'Add outcome'
  end

  def then_i_should_see_create_agreement_page
    expect(page).to have_content('Create agreement')
    expect(page).to have_content('Agreement for: Alan Sugar')
    expect(page).to have_content('Total arrears balance owed: £103.57')
    expect(page).to have_content('Court case related to this agreement')
    expect(page).to have_content('Court date: July 21st, 2020')
    expect(page).to have_content('Court outcome: Adjourned on Terms')
    expect(page).to have_content('Frequency of payments')
    expect(page).to have_content('Weekly instalment amount')
    expect(page).to have_content('Start date')
    expect(page).to have_content('Starting Balance')
    expect(page).to have_content('End date')
    expect(page).to have_content('Notes')
  end

  def then_i_should_see_the_starting_balance_field
    expect(page).to have_field('starting_balance', disabled: true)
    expect(find_field('starting_balance', disabled: true).value).to eq '103.57'
  end

  def when_i_fill_in_the_agreement_details
    select('Weekly', from: 'frequency')
    fill_in 'amount', with: '50'
    fill_in 'start_date', with: '12/12/2020'
    fill_in 'notes', with: 'Wen Ting is the master of rails'
  end

  def and_i_click_on_create
    click_button 'Create'
  end

  def then_i_should_see_the_agreement_page
    expect(page).to have_current_path(show_agreement_path(tenancy_ref: '1234567/01', id: '12'))
  end

  def and_i_can_not_see_the_button_to_send_agreement_confirmation_letter
    expect(page).to_not have_button('Send agreement confirmation letter')
  end

  def when_i_click_link_to_go_back_to_case_profile
    click_link 'Return to case profile'
  end

  def then_i_should_see_the_tenancy_page
    expect(page).to have_current_path(tenancy_path(id: '1234567/01'))
  end

  def and_i_should_see_the_new_agreement
    expect(page).to have_content('Arrears Agreement')
    expect(page).to have_content('Status')
    expect(page).to have_content('Live')
  end

  def and_i_should_see_the_agreement_status
    expect(page).to have_content('Status Live')
    expect(page).to have_content('End date December 26th, 2020')
    expect(page).to have_content("Current balance\n£53.57")
    expect(page).to have_content("Expected balance\n£53.57")
    expect(page).to have_content('Last checked')
    expect(page).to have_content('July 19th, 2020')
  end

  def stub_create_agreement_response
    request_body_json = {
      agreement_type: 'formal',
      frequency: 'weekly',
      amount: '50',
      start_date: '12/12/2020',
      created_by: 'Hackney User',
      notes: 'Wen Ting is the master of rails',
      court_case_id: '12'

    }.to_json

    response_json = {
      "id": 12,
      "tenancyRef": '1234567/01',
      "agreementType": 'formal',
      "startingBalance": '103.57',
      "amount": '50',
      "startDate": '2020-12-12',
      "frequency": 'weekly',
      "currentState": 'live',
      "createdAt": '2020-06-19',
      "createdBy": 'Hackney User',
      "lastChecked": '2020-06-19',
      "history": [
        {
          "state": 'live',
          "date": '2020-06-19',
          "expectedBalance": '103.57',
          "checkedBalance": '103.57',
          "description": 'Agreement created'
        }
      ]
    }.to_json

    stub_request(:post, 'https://example.com/income/api/v1/agreement/1234567%2F01/')
         .with(
           body: request_body_json,
           headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] }
         )
         .to_return(status: 200, body: response_json, headers: {})
  end

  def stub_view_agreements_response
    response_with_no_agreements_json = { "agreements": [] }.to_json
    response_with_live_agreement_json =
      {
        "agreements": [
          {
            "id": 12,
            "tenancyRef": '1234567/01',
            "agreementType": 'formal',
            "startingBalance": '103.57',
            "amount": '50',
            "startDate": '2020-12-12',
            "frequency": 'weekly',
            "currentState": 'live',
            "createdAt": '2020-06-19',
            "createdBy": 'Hackney User',
            "lastChecked": '2020-07-19',
            "notes": 'Wen Ting is the master of rails',
            "history": [
              {
                "state": 'live',
                "date": '2020-06-19',
                "expectedBalance": '103.57',
                "checkedBalance": '103.57',
                "description": 'Agreement created'
              },
              {
                "state": 'live',
                "date": '2020-07-19',
                "expectedBalance": '53.57',
                "checkedBalance": '53.57',
                "description": 'Checked by the system'
              }
            ]
          }
        ]
      }.to_json

    stub_request(:get, 'https://example.com/income/api/v1/agreements/1234567%2F01/')
      .with(
        headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] }
      )
      .to_return({ status: 200, body: response_with_no_agreements_json },
                 { status: 200, body: response_with_live_agreement_json },
                 status: 200, body: response_with_live_agreement_json)
  end

  def stub_cancel_agreement_response
    stub_request(:post, 'https://example.com/income/api/v1/agreements/12/cancel')
         .with(headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] })
         .to_return(status: 200, headers: {})
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

  def stub_update_court_outcome_response
    request_body_jsons = [
      {
        court_date: nil,
        court_outcome: 'ADT',
        balance_on_court_outcome_date: '1000',
        strike_out_date: '',
        terms: true,
        disrepair_counter_claim: false
      }.to_json
    ]

    request_body_jsons.each do |request|
      stub_request(:patch, 'https://example.com/income/api/v1/court_case/12/update')
          .with(
            body: request,
            headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] }
          )
          .to_return(status: 200, headers: {})
    end
  end

  def view_court_cases_responses
    no_court_cases_response_json = {
      courtCases: []
    }.to_json

    one_court_case_response_json = {
      courtCases: [{
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
      courtCases: [{
                    id: 12,
                    tenancyRef: '1234567/01',
                    courtDate: '2020-07-21T00:00:00.000Z',
                    courtOutcome: 'ADT',
                    balanceOnCourtOutcomeDate: 1000,
                    strikeOutDate: nil,
                    terms: true,
                    disrepairCounterClaim: false
                    }]
    }.to_json

    [no_court_cases_response_json, one_court_case_response_json, updated_court_case_response_json]
  end
end
