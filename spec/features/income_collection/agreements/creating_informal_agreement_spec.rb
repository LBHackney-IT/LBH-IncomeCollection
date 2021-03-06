require 'rails_helper'

describe 'Create informal agreement' do
  before do
    create_jwt_token

    stub_my_cases_response
    stub_income_api_show_tenancy
    stub_tenancy_api_payments
    stub_tenancy_api_contacts
    stub_tenancy_api_actions
    stub_tenancy_api_tenancy
    stub_create_agreement_response
    stub_create_one_off_payment_agreement_response
    stub_cancel_and_create_agreement_response
    stub_view_agreements_response
    stub_cancel_agreement_response
    stub_view_court_cases_responses
  end

  scenario 'creating a new informal agreement' do
    given_i_am_logged_in

    when_i_visit_a_tenancy_with_arrears
    and_i_click_on_create_agreement
    and_i_select_regular_payment_agreement
    then_i_should_see_create_agreement_page
    and_i_should_not_see_the_lump_sum_payment_fields

    when_i_fill_in_the_agreement_details
    and_i_click_on_create
    then_i_should_see_the_agreement_page
    and_i_can_see_a_button_to_send_agreement_confirmation_letter

    when_i_click_to_cancel_and_create_a_new_agreement
    and_i_select_one_off_payment_agreement
    then_i_should_see_create_one_off_payment_agreement_page

    when_i_fill_in_the_date_of_payment
    and_i_click_on_create
    then_i_should_see_the_new_one_off_payment_agreement_page
    and_i_should_see_the_one_off_payment_details
    and_i_can_see_a_button_to_send_agreement_confirmation_letter

    when_i_click_to_cancel_and_create_a_new_agreement
    and_i_select_variable_payment_agreement
    then_i_should_see_create_agreement_page
    and_i_should_see_the_lump_sum_payment_fields

    when_i_fill_in_the_agreement_details
    and_i_fill_in_the_lump_sum_payment_details
    and_i_click_on_create
    then_i_should_see_the_new_variable_payment_agreement_page
    and_i_can_see_the_lump_sum_payment_details
    and_i_can_see_a_button_to_send_agreement_confirmation_letter

    when_i_click_link_to_go_back_to_case_profile
    then_i_should_see_the_tenancy_page
    and_i_should_see_the_new_agreement
    and_i_should_see_the_agreement_status
    and_i_should_see_a_button_to_cancel_and_create_new_agreement
    and_i_should_see_a_link_to_view_details
    and_i_should_see_a_link_to_view_history

    when_i_click_on_view_details
    and_i_click_on_cancel
    then_i_am_asked_to_confirm_cancellation

    when_i_fill_up_the_cancellation_reason
    and_i_confirm_to_cancel_the_agreement
    then_i_should_see_the_tenancy_page
    and_i_should_not_see_a_live_agreement
    and_i_should_see_a_link_to_view_history

    and_i_click_on_view_history
    then_i_should_see_the_agreements_history_page
    and_i_should_see_the_agreements_history_with_a_cancelled_agreement
  end

  def when_i_visit_a_tenancy_with_arrears
    visit tenancy_path(id: '1234567/01')
  end

  def and_i_click_on_create_agreement
    click_link 'Create agreement'
  end

  def and_i_select_one_off_payment_agreement
    choose('payment_type_one_off')
    click_button 'Continue'
  end

  def then_i_should_see_create_one_off_payment_agreement_page
    expect(page).to have_content('Create informal agreement')
    expect(page).to have_content('Agreement for: Alan Sugar')
    expect(find_field('starting_balance', disabled: true).value).to eq '103.57'
    expect(page).to have_content('Payment date')
  end

  def when_i_fill_in_the_date_of_payment
    fill_in 'start_date', with: '10/12/2020'
  end

  def then_i_should_see_the_new_one_off_payment_agreement_page
    expect(page).to have_current_path(show_agreement_path(tenancy_ref: '1234567/01', id: '11'))
  end

  def and_i_should_see_the_one_off_payment_details
    expect(page).to have_content('One off payment')
    expect(page).to have_content('Payment amount: £103.57')
    expect(page).to have_content('Payment date: December 10th, 2020')
    expect(page).not_to have_content('Start date')
  end

  def and_i_select_regular_payment_agreement
    choose('payment_type_regular')
    click_button 'Continue'
  end

  def then_i_should_see_create_agreement_page
    expect(page).to have_content('Create informal agreement')
    expect(page).to have_content('Agreement for: Alan Sugar')
    expect(page).to have_content('Total arrears balance owed: £103.57')
    expect(page).to have_content('Frequency of payments')
    expect(page).to have_content('Weekly instalment amount')
    expect(page).to have_content('Start date')
    expect(page).to have_content('End date')
    expect(page).to have_content('Notes')
  end

  def and_i_should_not_see_the_lump_sum_payment_fields
    expect(page).not_to have_content('Lump sum payment amount')
    expect(page).not_to have_content('Lump sum payment date')
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

  def and_i_can_see_a_button_to_send_agreement_confirmation_letter
    expect(page).to have_button('Send agreement confirmation letter')
  end

  def when_i_click_to_cancel_and_create_a_new_agreement
    click_link 'Cancel and create new'
  end

  def and_i_select_variable_payment_agreement
    choose('payment_type_variable')
    click_button 'Continue'
  end

  def and_i_should_see_the_lump_sum_payment_fields
    expect(page).to have_content('Lump sum payment amount')
    expect(page).to have_content('Lump sum payment date')
  end

  def and_i_fill_in_the_lump_sum_payment_details
    fill_in 'initial_payment_amount', with: '80'
    fill_in 'initial_payment_date', with: '12/12/2020'
  end

  def then_i_should_see_the_new_variable_payment_agreement_page
    expect(page).to have_current_path(show_agreement_path(tenancy_ref: '1234567/01', id: '13'))
  end

  def and_i_can_see_the_lump_sum_payment_details
    expect(page).to have_content('Lump sum payment amount: £80.0')
    expect(page).to have_content('Lump sum payment date: December 12th, 2020')
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

  def and_i_should_see_a_button_to_cancel_and_create_new_agreement
    expect(page).to have_link('Cancel and create new')
  end

  def and_i_should_see_a_link_to_view_details
    expect(page).to have_link(href: '/tenancies/1234567%2F01/agreement/13/show')
  end

  def and_i_should_see_a_link_to_view_history
    expect(page).to have_link('View history')
  end

  def when_i_click_on_view_details
    click_link 'View details'
  end

  def and_i_should_see_the_agreement_status
    expect(page).to have_content('Status Live')
    expect(page).to have_content('End date December 12th, 2020')
    expect(page).to have_content("Current balance\n£53.57")
    expect(page).to have_content("Expected balance\n£53.57")
    expect(page).to have_content('Last checked')
    expect(page).to have_content('July 19th, 2020')
  end

  def and_i_click_on_cancel
    click_link 'Cancel'
  end

  def then_i_am_asked_to_confirm_cancellation
    expect(page).to have_content('Are you sure you want to cancel this agreement?')
  end

  def when_i_fill_up_the_cancellation_reason
    fill_in 'cancellation_reason', with: 'needed to cancel'
  end

  def and_i_confirm_to_cancel_the_agreement
    click_button 'Confirm and cancel'
  end

  def and_i_should_not_see_a_live_agreement
    expect(page).to have_content('There is currently no live agreement')
  end

  def and_i_click_on_view_history
    click_link 'View history'
  end

  def then_i_should_see_the_agreements_history_page
    expect(page).to have_content('History of agreements')
    expect(page).to have_content('All agreements associated with Alan Sugar')
  end

  def and_i_should_see_the_agreements_history_with_a_cancelled_agreement
    agreements_history_table = find('table')

    expect(agreements_history_table).to have_content('Status')
    expect(agreements_history_table).to have_content('Cancelled')

    expect(agreements_history_table).to have_content('Start date')
    expect(agreements_history_table).to have_content('December 12th, 2020')

    expect(agreements_history_table).to have_content('End date')
    expect(agreements_history_table).to have_content('December 26th, 2020')

    expect(agreements_history_table).to have_content('Balance owed')
    expect(agreements_history_table).to have_content('£103.57')

    expect(agreements_history_table).to have_content('Description')
    expect(agreements_history_table).to have_content('Cancelled on 20/07/2020')

    expect(agreements_history_table).to have_link('View details').once
  end

  def stub_create_agreement_response
    request_body_json = {
      agreement_type: 'informal',
      frequency: 'weekly',
      amount: '50',
      start_date: '12/12/2020',
      created_by: 'Hackney User',
      notes: 'Wen Ting is the master of rails',
      court_case_id: nil,
      initial_payment_amount: nil,
      initial_payment_date: nil
    }.to_json

    response_json = {
      "id": 12,
      "tenancyRef": '1234567/01',
      "agreementType": 'informal',
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

  def stub_create_one_off_payment_agreement_response
    request_body_json = {
      agreement_type: 'informal',
      frequency: 'one_off',
      amount: '103.57',
      start_date: '10/12/2020',
      created_by: 'Hackney User',
      notes: nil,
      court_case_id: nil,
      initial_payment_amount: nil,
      initial_payment_date: nil
    }.to_json

    response_json = {
      "id": 11,
      "tenancyRef": '1234567/01',
      "agreementType": 'informal',
      "startingBalance": '103.57',
      "amount": '103.57',
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

  def stub_cancel_and_create_agreement_response
    request_body_json = {
      agreement_type: 'informal',
      frequency: 'weekly',
      amount: '50',
      start_date: '12/12/2020',
      created_by: 'Hackney User',
      notes: 'Wen Ting is the master of rails',
      court_case_id: nil,
      initial_payment_amount: '80',
      initial_payment_date: '12/12/2020'
    }.to_json

    response_json = {
      "id": 13,
      "tenancyRef": '1234567/01',
      "agreementType": 'informal',
      "startingBalance": '103.57',
      "amount": '50',
      "startDate": '2020-12-12',
      "frequency": 'weekly',
      "currentState": 'live',
      "createdAt": '2020-06-19',
      "createdBy": 'Hackney User',
      "lastChecked": '2020-06-19',
      "initialPaymentAmount": '80',
      "initialPaymentDate": '2020-12-12',
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
            "agreementType": 'informal',
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
            "id": 11,
            "tenancyRef": '1234567/01',
            "agreementType": 'informal',
            "startingBalance": '103.57',
            "amount": '103.57',
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
                "expectedBalance": '103.57',
                "checkedBalance": '103.57',
                "description": 'Agreement created'
              }
            ]
          }
        ]
      }.to_json

    response_with_live_variable_payment_agreement_json =
      {
        "agreements": [
          {
            "id": 13,
            "tenancyRef": '1234567/01',
            "agreementType": 'informal',
            "startingBalance": '103.57',
            "amount": '50',
            "startDate": '2020-12-12',
            "frequency": 'weekly',
            "currentState": 'live',
            "createdAt": '2020-06-19',
            "createdBy": 'Hackney User',
            "lastChecked": '2020-07-19',
            "notes": 'Wen Ting is the master of rails',
            "initialPaymentAmount": '80',
            "initialPaymentDate": '2020-12-12',
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

    response_with_cancelled_agreement_json =
      {
        "agreements": [
          {
            "id": 13,
            "tenancyRef": '1234567/01',
            "agreementType": 'informal',
            "startingBalance": '103.57',
            "amount": '50',
            "startDate": '2020-12-12',
            "frequency": 'weekly',
            "currentState": 'cancelled',
            "createdAt": '2020-06-19',
            "createdBy": 'Hackney User',
            "lastChecked": '2020-07-20',
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
              },
              {
                "state": 'cancelled',
                "date": '2020-07-20',
                "expectedBalance": '',
                "checkedBalance": '',
                "description": 'Cancelled on 20/07/2020'
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
                 { status: 200, body: response_with_live_one_off_payment_agreement_json },
                 { status: 200, body: response_with_live_variable_payment_agreement_json },
                 { status: 200, body: response_with_live_variable_payment_agreement_json },
                 { status: 200, body: response_with_live_variable_payment_agreement_json },
                 status: 200, body: response_with_cancelled_agreement_json)
  end

  def stub_cancel_agreement_response
    request_body_json = {
      cancelled_by: 'Hackney User',
      cancellation_reason: 'needed to cancel'
    }.to_json

    stub_request(:post, 'https://example.com/income/api/v1/agreements/13/cancel')
         .with(
           body: request_body_json,
           headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] }
         )
         .to_return(status: 200, headers: {})
  end
end
