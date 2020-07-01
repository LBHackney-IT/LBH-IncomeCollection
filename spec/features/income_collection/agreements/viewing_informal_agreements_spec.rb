require 'rails_helper'

describe 'Viewing informal agreements' do
  before do
    FeatureFlag.activate('create_informal_agreements')

    create_jwt_token

    stub_my_cases_response
    stub_tenancy_with_arrears
    stub_tenancy_api_payments
    stub_tenancy_api_contacts
    stub_tenancy_api_actions
    stub_tenancy_api_tenancy
    # stub_create_agreement_response
    stub_view_agreements_response
  end

  after do
    FeatureFlag.deactivate('create_informal_agreements')
  end

  scenario 'viewing all informal agreements' do
    given_i_am_logged_in

    when_i_visit_a_tenancy_with_arrears
    and_i_should_see_a_link_to_view_history
    and_i_click_on_view_history
    then_i_should_see_the_agreements_history_page
    # and_i_should_see_the_new_agreement
    # and_i_should_see_a_button_to_cancel_and_create_new_agreement
  end

  def when_i_visit_a_tenancy_with_arrears
    visit tenancy_path(id: '1234567/01')
  end

  # def and_i_click_on_create_agreement
  #   click_link 'Create agreement'
  # end

  # def then_i_should_see_create_agreement_page
  #   expect(page).to have_content('Create agreement')
  #   expect(page).to have_content('Agreement for: Alan Sugar')
  #   expect(page).to have_content('Total arrears balance owed: £103.57')
  # end

  # def when_i_fill_in_the_agreement_details
  #   select('Weekly', from: 'frequency')
  #   fill_in 'instalment_amount', with: '50'
  #   fill_in 'start_date', with: '12/12/2020'
  # end



  # def and_i_should_see_the_new_agreementf
  #   expect(page).to have_content('Arrears Agreement')
  #   expect(page).to have_content('Status: Live')
  #   expect(page).to have_content('Expected balance: £103.57')
  #   expect(page).to have_content('Actual balance: £103.57')
  #   expect(page).to have_content('Last checked:')
  # end

  def and_i_should_see_a_link_to_view_history
    expect(page).to have_link('View history')
  end

  def and_i_click_on_view_history
    click_link 'View history'
  end

  def then_i_should_see_the_agreements_history_page
    expect(page).to have_content('History of agreements')
    # expect(page).to have_content('All agreements associated with ')
    # expect(page).to have_content('Total arrears balance owed: £103.57')
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

  # def stub_create_agreement_response
  #   request_body_json = {
  #     agreement_type: 'informal',
  #     frequency: 'weekly',
  #     amount: '50',
  #     start_date: '12/12/2020'
  #   }.to_json

  #   response_json = {
  #     "id": 12,
  #     "tenancyRef": '1234567/01',
  #     "agreementType": 'informal',
  #     "startingBalance": '103.57',
  #     "amount": '50',
  #     "startDate": '2020-06-19',
  #     "frequency": 'weekly',
  #     "currentState": 'live',
  #     "history": [
  #       {
  #         "state": 'live',
  #         "date": '2020-06-19'
  #       }
  #     ]
  #   }.to_json

  #   stub_request(:post, 'https://example.com/income/api/v1/agreement/1234567%2F01/')
  #        .with(
  #          body: request_body_json,
  #          headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] }
  #        )
  #        .to_return(status: 200, body: response_json, headers: {})
  # end

  def stub_view_agreements_response
    response_json =
      {
        "agreements": [
          {
            "id": 12,
            "tenancyRef": '1234567/01',
            "agreementType": 'informal',
            "startingBalance": '103.57',
            "amount": '50',
            "startDate": '2020-06-19',
            "frequency": 'weekly',
            "currentState": 'live',
            "history": [
              {
                "state": 'live',
                "date": '2020-06-19'
              }
            ]
          }
        ]
      }.to_json

    stub_request(:get, 'https://example.com/income/api/v1/agreements/1234567%2F01/')
      .with(
        headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] }
      )
      .to_return(status: 200, body: response_json)
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
