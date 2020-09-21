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
    stub_create_one_off_paymenent_agreement_response
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
    then_i_am_asked_to_select_the_payment_type_of_the_agreement
    and_i_should_see_create_agreement_page
    and_i_should_see_the_starting_balance_field

    when_i_fill_in_the_agreement_details
    and_i_click_on_create
    then_i_should_see_the_agreement_page
    and_i_can_not_see_the_button_to_send_agreement_confirmation_letter
    and_i_should_see_send_confirmation_letter_button

    when_i_click_to_cancel_and_create_a_new_agreement
    and_i_select_one_off_payment_agreement
    then_i_should_see_create_one_off_payment_agreement_page

    when_i_fill_in_the_date_of_payment
    and_i_click_on_create
    then_i_should_see_the_new_one_off_payment_agreement_page
    and_i_should_see_the_one_off_payment_details
    and_i_should_see_send_confirmation_letter_button

    when_i_click_link_to_go_back_to_case_profile
    then_i_should_see_the_tenancy_page
    and_i_should_see_the_new_agreement
    and_i_should_see_the_agreement_status
    and_i_should_see_cancel_and_create_new_button

    and_i_create_a_new_court_case
    and_i_should_see_the_cancel_button
  end

  def when_i_visit_a_tenancy_with_arrears
    visit tenancy_path(id: '1234567/01')
  end

  def and_i_create_a_court_case_with_an_outcome_with_terms
    click_link 'Add court date'
    fill_in 'court_date', with: '21/07/2020'
    fill_in 'court_time', with: '09:00'
    click_button 'Add'

    click_link 'Add court outcome'
    choose('court_outcome_ADT')
    fill_in 'balance_on_court_outcome_date', with: '1000'
    click_button 'Add outcome'

    choose('terms_Yes')
    choose('disrepair_counter_claim_No')
    click_button 'Add outcome'
  end

  def and_i_create_a_new_court_case
    stub_view_court_cases_responses(responses: [{
        courtCases: [{
                         id: 12,
                         tenancyRef: '1234567/01',
                         courtDate: '2020-07-21T09:00:00.000Z',
                         courtOutcome: 'ADT',
                         balanceOnCourtOutcomeDate: 1000,
                         strikeOutDate: nil,
                         terms: true,
                         disrepairCounterClaim: false
                     }, {
                         id: 13,
                         tenancyRef: '1234567/01',
                         courtDate: '2020-08-22T09:30:00.000Z',
                         courtOutcome: nil,
                         balanceOnCourtOutcomeDate: nil,
                         strikeOutDate: nil,
                         terms: nil,
                         disrepairCounterClaim: nil
                     }]
    }.to_json])

    court_date = '22/08/2020'
    court_time = '09:30'

    stub_create_court_case_response("#{court_date} #{court_time}")

    click_link 'Cancel and create new court case'
    fill_in 'court_date', with: court_date
    fill_in 'court_time', with: court_time
    click_button 'Add'
  end

  def then_i_am_asked_to_select_the_payment_type_of_the_agreement
    choose('payment_type_regular')
    click_button 'Continue'
  end

  def and_i_should_see_create_agreement_page
    expect(page).to have_content('Create court agreement')
    expect(page).to have_content('Agreement for: Alan Sugar')
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

  def and_i_should_see_the_starting_balance_field
    expect(page).to have_field('starting_balance', disabled: true)
    expect(find_field('starting_balance', disabled: true).value).to eq '1000'
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
    expect(page).to have_content('Court ordered agreement')
    expect(page).to have_content('Arrears Agreement')
    expect(page).to have_content('Status')
    expect(page).to have_content('Live')
  end

  def and_i_should_see_the_agreement_status
    expect(page).to have_content('Status Live')
    expect(page).to have_content('End date December 10th, 2020')
    expect(page).to have_content("Current balance\n£1,000.00")
    expect(page).to have_content("Expected balance\n£1,000.00")
    expect(page).to have_content('Last checked')
    expect(page).to have_content('July 19th, 2020')
  end

  def and_i_should_see_send_confirmation_letter_button
    expect(page).to have_button('Send court outcome confirmation letter')
  end

  def when_i_click_to_cancel_and_create_a_new_agreement
    click_link 'Cancel and create new'
  end

  def and_i_select_one_off_payment_agreement
    choose('payment_type_one_off')
    click_button 'Continue'
  end

  def then_i_should_see_create_one_off_payment_agreement_page
    expect(page).to have_content('Create court agreement')
    expect(page).to have_content('Agreement for: Alan Sugar')
    expect(find_field('starting_balance', disabled: true).value).to eq '1000'
    expect(page).to have_content('Payment date')
  end

  def when_i_fill_in_the_date_of_payment
    fill_in 'start_date', with: '10/12/2020'
  end

  def then_i_should_see_the_new_one_off_payment_agreement_page
    expect(page).to have_current_path(show_agreement_path(tenancy_ref: '1234567/01', id: '13'))
  end

  def and_i_should_see_the_one_off_payment_details
    expect(page).to have_content('One off payment')
    expect(page).to have_content('Payment amount: £1,000.00')
    expect(page).to have_content('Payment date: December 10th, 2020')
    expect(page).not_to have_content('Start date')
  end

  def and_i_should_see_cancel_and_create_new_button
    expect(page).to have_content('Cancel and create new court ordered agreement')
  end

  def and_i_should_see_the_cancel_button
    expect(page).to have_content('Cancel agreement')
  end

  def stub_create_agreement_response
    request_body_json = {
      agreement_type: 'formal',
      frequency: 'weekly',
      amount: '50',
      start_date: '12/12/2020',
      created_by: 'Hackney User',
      notes: 'Wen Ting is the master of rails',
      court_case_id: '12',
      initial_payment_amount: nil,
      initial_payment_date: nil
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

  def stub_create_one_off_paymenent_agreement_response
    request_body_json = {
      agreement_type: 'formal',
      frequency: 'one_off',
      amount: '1000',
      start_date: '10/12/2020',
      created_by: 'Hackney User',
      notes: nil,
      court_case_id: '12',
      initial_payment_amount: nil,
      initial_payment_date: nil
    }.to_json

    response_json = {
      "id": 13,
      "tenancyRef": '1234567/01',
      "agreementType": 'formal',
      "startingBalance": '1000',
      "amount": '1000',
      "startDate": '2020-12-10',
      "frequency": 'one_off',
      "currentState": 'live',
      "createdAt": '2020-06-19',
      "createdBy": 'Hackney User',
      "lastChecked": '2020-06-19',
      "history": [
        {
          "state": 'live',
          "date": '2020-06-19',
          "expectedBalance": '1000',
          "checkedBalance": '1000',
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

    response_with_live_one_off_payment_agreement_json =
      {
        "agreements": [
          {
            "id": 13,
            "tenancyRef": '1234567/01',
            "agreementType": 'formal',
            "startingBalance": '1000',
            "amount": '1000',
            "startDate": '2020-12-10',
            "frequency": 'one_off',
            "currentState": 'live',
            "createdAt": '2020-06-19',
            "createdBy": 'Hackney User',
            "lastChecked": '2020-07-19',
            "history": [
              {
                "state": 'live',
                "date": '2020-06-19',
                "expectedBalance": '1000',
                "checkedBalance": '1000',
                "description": 'Agreement created'
              },
              {
                "state": 'live',
                "date": '2020-07-19',
                "expectedBalance": '1000',
                "checkedBalance": '1000',
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
                 { status: 200, body: response_with_live_agreement_json },
                 status: 200, body: response_with_live_one_off_payment_agreement_json)
  end

  def stub_cancel_agreement_response
    stub_request(:post, 'https://example.com/income/api/v1/agreements/12/cancel')
         .with(headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] })
         .to_return(status: 200, headers: {})
  end

  def stub_create_court_case_response(court_date = '21/07/2020 09:00')
    request_body_json = {
      court_date: court_date,
      court_outcome: nil,
      balance_on_court_outcome_date: nil,
      strike_out_date: nil,
      terms: nil,
      disrepair_counter_claim: nil
    }.to_json

    response_json = {
      id: 12,
      tenancyRef: '1234567/01',
      courtDate: court_date,
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
        courtDate: '21/07/2020 09:00',
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
                    courtDate: '2020-07-21T09:00:00.000Z',
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
