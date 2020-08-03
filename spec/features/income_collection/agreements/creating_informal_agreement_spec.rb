require 'rails_helper'

describe 'Create informal agreement' do
  before do
    FeatureFlag.activate('create_informal_agreements')

    create_jwt_token

    stub_my_cases_response
    stub_tenancy_with_arrears
    stub_tenancy_api_payments
    stub_tenancy_api_contacts
    stub_tenancy_api_actions
    stub_tenancy_api_tenancy
    stub_create_agreement_response
    stub_view_agreements_response
    stub_cancel_agreement_response
  end

  after do
    FeatureFlag.deactivate('create_informal_agreements')
  end

  scenario 'creating a new informal agreement' do
    given_i_am_logged_in

    when_i_visit_a_tenancy_with_arrears
    and_i_click_on_create_agreement
    then_i_should_see_create_agreement_page

    when_i_fill_in_the_agreement_details
    and_i_click_on_create
    then_i_should_see_the_tenancy_page
    and_i_should_see_the_new_agreement
    and_i_should_see_the_agreement_status
    and_i_should_see_a_button_to_cancel_and_create_new_agreement
    and_i_should_see_a_link_to_view_details
    and_i_should_see_a_link_to_view_history

    when_i_click_on_view_details
    then_i_should_see_the_agreement_details_page
    and_i_should_see_the_agreement_status
    and_i_should_see_the_agreement_details
    and_i_should_see_a_button_to_cancel_and_create_new_agreement
    and_i_should_see_the_agreement_state_history
    and_i_should_see_a_button_to_cancel_the_agreement

    when_i_click_on_cancel
    then_i_am_asked_to_confirm_cancellation

    when_i_confirm_to_cancel_the_agreement
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

  def then_i_should_see_create_agreement_page
    expect(page).to have_content('Create agreement')
    expect(page).to have_content('Agreement for: Alan Sugar')
    expect(page).to have_content('Total arrears balance owed: £103.57')
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
    expect(page).to have_link(href: '/tenancies/1234567%2F01/agreement/12/show')
  end

  def and_i_should_see_a_link_to_view_history
    expect(page).to have_link('View history')
  end

  def when_i_click_on_view_details
    click_link 'View details'
  end

  def then_i_should_see_the_agreement_details_page
    expect(page).to have_content('Agreement')
    expect(page).to have_content('Alan Sugar')
  end

  def and_i_should_see_the_agreement_status
    expect(page).to have_content('Status Live')
    expect(page).to have_content("Current balance\n£53.57")
    expect(page).to have_content("Expected balance\n£53.57")
    expect(page).to have_content('Last checked')
    expect(page).to have_content('July 19th, 2020')
  end

  def and_i_should_see_the_agreement_details
    expect(page).to have_content('Created: June 19th, 2020')
    expect(page).to have_content('Created by: Hackney User')
    expect(page).to have_content('Notes: Wen Ting is the master of rails')

    expect(page).to have_content('Total balance owed: £103.57')
    expect(page).to have_content('Frequency of payment: Weekly')
    expect(page).to have_content('Instalment amount: £50')
    expect(page).to have_content('Start date: December 12th, 2020')
    expect(page).to have_content('End date: December 26th, 2020')
  end

  def and_i_should_see_the_agreement_state_history
    expect(page).to have_content('History')
    agreement_history_table = find('table')

    expect(agreement_history_table).to have_content('Date')
    expect(agreement_history_table).to have_content('June 19th, 2020')
    expect(agreement_history_table).to have_content('July 19th, 2020')
    expect(agreement_history_table).to have_content('Status')
    expect(agreement_history_table).to have_content('Live')
    expect(agreement_history_table).to have_content('Description')
    expect(agreement_history_table).to have_content('Agreement created')
  end

  def and_i_should_see_a_button_to_cancel_the_agreement
    expect(page).to have_link('Cancel')
  end

  def when_i_click_on_cancel
    click_link 'Cancel'
  end

  def then_i_am_asked_to_confirm_cancellation
    expect(page).to have_content('Are you sure you want to cancel this agreement?')
  end

  def when_i_confirm_to_cancel_the_agreement
    click_link 'Yes'
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

  def stub_create_agreement_response
    request_body_json = {
      agreement_type: 'informal',
      frequency: 'weekly',
      amount: '50',
      start_date: '12/12/2020',
      created_by: 'Hackney User',
      notes: 'Wen Ting is the master of rails'
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

    response_with_cancelled_agreement_json =
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
                 { status: 200, body: response_with_live_agreement_json },
                 status: 200, body: response_with_cancelled_agreement_json)
  end

  def stub_cancel_agreement_response
    stub_request(:post, 'https://example.com/income/api/v1/agreements/12/cancel')
         .with(headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] })
         .to_return(status: 200, headers: {})
  end

  def stub_tenancy_api_payments
    response_json = { 'payment_transactions': [] }.to_json

    stub_request(:get, 'https://example.com/tenancy/api/v1/tenancies/1234567%2F01/payments')
      .with(headers: { 'X-Api-Key' => ENV['TENANCY_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_tenancy_api_contacts
    response_json = { data: { contacts: [] } }.to_json

    stub_request(:get, 'https://example.com/tenancy/api/v1/tenancies/1234567%2F01/contacts')
      .with(headers: { 'X-Api-Key' => ENV['TENANCY_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_tenancy_api_actions
    response_json = { arrears_action_diary_events: [] }.to_json

    stub_request(:get, 'https://example.com/tenancy/api/v1/tenancies/1234567%2F01/actions')
      .with(headers: { 'X-Api-Key' => ENV['TENANCY_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_tenancy_api_tenancy
    response_json = File.read(Rails.root.join('spec', 'examples', 'single_case_response.json'))

    stub_request(:get, 'https://example.com/tenancy/api/v1/tenancies/1234567%2F01')
      .with(headers: { 'X-Api-Key' => ENV['TENANCY_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end
end
