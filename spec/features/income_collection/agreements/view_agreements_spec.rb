require 'rails_helper'

describe 'View agreements' do
  before do
    create_jwt_token

    stub_my_cases_response
    stub_income_api_show_tenancy
    stub_tenancy_api_payments
    stub_tenancy_api_contacts
    stub_tenancy_api_actions
    stub_tenancy_api_tenancy
    stub_view_court_cases_responses
  end

  scenario 'viewing agreement' do
    given_i_am_logged_in
    and_there_there_is_a_breached_informal_agreement_with_variable_payments

    when_i_visit_the_tenancy_page
    then_i_should_see_the_breached_agreement_status
    and_i_should_see_a_button_to_send_breach_letter

    when_i_click_on_view_details
    then_i_should_see_the_agreement_details_page
    and_i_should_see_the_agreement_status
    and_i_should_see_the_agreement_details
    and_i_should_see_a_button_to_send_breach_letter
    and_i_should_see_a_button_to_cancel_and_create_new_agreement
    and_i_should_see_a_button_to_cancel_the_agreement
    and_i_should_see_the_agreement_state_history
  end

  def and_there_there_is_a_breached_informal_agreement_with_variable_payments
    breached_agreement =
      {
        "agreements": [
          {
            "id": 12,
            "tenancyRef": '1234567/01',
            "agreementType": 'informal',
            "startingBalance": '170.60',
            "amount": '20',
            "startDate": '2020-12-12',
            "frequency": 'weekly',
            "currentState": 'breached',
            "createdAt": '2020-06-19',
            "createdBy": 'Hackney User',
            "lastChecked": '2020-07-19',
            "notes": 'Wen Ting is the master of rails',
            "initialPaymentDate": '2020-12-11',
            "initialPaymentAmount": '30.60',
            "history": [
              {
                "state": 'breached',
                "date": '2020-06-19',
                "expectedBalance": '100',
                "checkedBalance": '120',
                "description": 'Breached by £20'
              }
            ]
          }
        ]
      }.to_json

    stub_view_agreements_response(response: breached_agreement)
  end

  def when_i_visit_the_tenancy_page
    visit tenancy_path(id: '1234567/01')
  end

  def then_i_should_see_the_breached_agreement_status
    expect(page).to have_content('Breached (Breached by £20)')
    expect(page).to have_content("Current balance\n£120.0")
    expect(page).to have_content("Expected balance\n£100.0")
    expect(page).to have_content('Last checked')
    expect(page).to have_content('July 19th, 2020')
  end

  def and_i_should_see_a_button_to_send_breach_letter
    expect(page).to have_button('Send agreement breach letter')
  end

  def when_i_click_on_view_details
    click_link 'View details'
  end

  def then_i_should_see_the_agreement_details_page
    expect(page).to have_content('Agreement')
    expect(page).to have_content('Alan Sugar')
  end

  def and_i_should_see_the_agreement_status
    expect(page).to have_content('Status Breached (Breached by £20)')
    expect(page).to have_content("Current balance\n£120")
    expect(page).to have_content("Expected balance\n£100")
    expect(page).to have_content('Last checked')
    expect(page).to have_content('July 19th, 2020')
  end

  def and_i_should_see_the_agreement_details
    expect(page).to have_content('Created: June 19th, 2020')
    expect(page).to have_content('Created by: Hackney User')
    expect(page).to have_content('Notes: Wen Ting is the master of rails')

    expect(page).to have_content('Total balance owed: £170.60')

    expect(page).to have_content('Lump sum payment amount: £30.60')
    expect(page).to have_content('Lump sum payment date: December 11th, 2020')

    expect(page).to have_content('Frequency of payment: Weekly')
    expect(page).to have_content('Instalment amount: £20')
    expect(page).to have_content('Start date: December 12th, 2020')
    expect(page).to have_content('End date: January 23rd, 2021')
  end

  def and_i_should_see_a_button_to_cancel_and_create_new_agreement
    expect(page).to have_link('Cancel and create new')
  end

  def and_i_should_see_a_button_to_cancel_the_agreement
    expect(page).to have_link('Cancel')
  end

  def and_i_should_see_the_agreement_state_history
    expect(page).to have_content('History')
    agreement_history_table = find('table')

    expect(agreement_history_table).to have_content('Date')
    expect(agreement_history_table).to have_content('June 19th, 2020')
    expect(agreement_history_table).to have_content('Status')
    expect(agreement_history_table).to have_content('Breached')
    expect(agreement_history_table).to have_content('Description')
    expect(agreement_history_table).to have_content('Breached Breached by £20')
  end
end
