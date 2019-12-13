require 'rails_helper'

describe 'Sending an income collection letter' do
  before do
    create_jwt_token
    stub_tenancy_api_my_cases
    stub_income_api_contacts
    stub_tenancy_api_show_tenancy
    stub_income_api_actions
    stub_income_api_payments
    stub_income_api_tenancy
    stub_income_collection_preview
  end

  scenario do
    given_i_am_logged_in
    when_i_visit_the_homepage
    then_i_should_see_cases_assigned_to_me
    i_then_click_on_a_case
    i_then_visit_income_collection_letters
    i_then_click_confirm_and_send_all
  end

  def when_i_visit_the_homepage
    visit '/'
  end

  def then_i_should_see_cases_assigned_to_me
    expect(page.body).to have_css('h2', text: 'Your Worktray', count: 1)
    expect(page).to have_field('immediateactions_tab', checked: true)
    expect(page.body).to have_content('TEST/01')
    expect(page.body).to have_content('TEST/02')
  end

  def i_then_click_on_a_case
    visit tenancy_path(id: 'TEST/01')
    expect(page).to have_content('Reference number: 1234567/01')
  end

  def i_then_visit_income_collection_letters
    click_button 'Send Letter One'
    expect(page).to have_content('Template name: Income collection letter 1')
  end

  def i_then_click_confirm_and_send_all
    click_button 'Confirm and Send All'
  end


  def stub_income_collection_preview
    response_json = {
      case: {
        tenancy_ref: '12345',
        payment_ref:'12345',
        address_line1: 'Test Line 1',
        address_line2: 'Test Line 2',
        address_line3: '',
        address_line4: '',
        address_name_number: '',
        address_post_code: 'HA7 2BL',
        address_preamble: 'random address',
        property_ref: '12345',
        forename: 'Test Forename',
        surname: 'Test Surname',
        title: 'Test Title',
        total_collectable_arrears_balance: '123'
      },
      template: {
        path: 'lib/hackney/pdf/templates/income/income_collection_letter_1.erb',
        name: 'Income collection letter 1',
        id: 'income_collection_letter_1'
      },
      username: 'eminem',
      document_id: 1,
      errors: []
    }.to_json

    stub_request(:post, "https://example.com/income/apiv1/messages/letters").
         with(
          body: "{\"payment_ref\":null,\"tenancy_ref\":\"1234567/01\",\"template_id\":\"income_collection_letter_1\",\"user\":{\"id\":\"100518888746922116647\",\"name\":\"Hackney User\",\"email\":\"hackney.user@test.hackney.gov.uk\",\"groups\":[\"income-collection-group-1\",\"group 2\"]}}",
          headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type'=>'application/json',
          'Host'=>'example.com',
          'User-Agent'=>'Ruby',
          'X-Api-Key'=>'TEST_API_KEY'
           }).
        to_return(status: 200, body: response_json, headers: {})
  end

  def stub_income_api_tenancy
    response_json = File.read(Rails.root.join('spec', 'examples', 'single_case_response.json'))

    stub_request(:get, 'https://example.com/tenancy/api/v1/tenancies/TEST%2F01')
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_income_api_payments
    response_json = {
      payment_transactions: [
        {
          ref: '',
          amount: '¤93.38',
          date: '2019-09-05 00:00:00Z',
          type: 'DBR',
          property_ref: '00042611    ',
          description: 'Basic Rent (No VAT) '
        },
        {
          ref: '',
          amount: '¤5.63',
          date: '2010-09-05 00:00:00Z',
          type: 'DCB',
          property_ref: '00042611',
          description: 'Cleaning (Block)'
        }
      ]
    }.to_json

    stub_request(:get, 'https://example.com/tenancy/api/v1/tenancies/TEST%2F01/payments')
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_income_api_contacts
    response_json = {
      data: {
        contacts: [{
          post_code: 'E8 1DY',
          responsible: true,
          address_line1: 'Primary Street',
          title: 'Mr',
          first_name: 'Alan',
          last_name: 'Sugar',
          email_address: 'alan.sugar@example.com'
        }]
      }
    }.to_json

    stub_request(:get, 'https://example.com/tenancy/api/v1/tenancies/TEST%2F01/contacts')
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_tenancy_api_my_cases
    response_json = File.read(Rails.root.join('spec', 'examples', 'my_cases_response.json'))

    stub_request(:get, 'https://example.com/income/api/v1/cases')
      .with(query: hash_including(
        is_paused: 'false',
        number_per_page: '20',
        page_number: '1'
      ))
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_tenancy_api_show_tenancy
    response_json = File.read(Rails.root.join('spec', 'examples', 'single_case_priority_response.json'))

    stub_request(:get, 'https://example.com/income/api/v1/tenancies/TEST%2F01')
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_income_api_actions
    response_json = {
      arrears_action_diary_events: [
        {
          code: 'INC',
          date: '01-01-2019',
          comment: 'Example details of a particular call',
          universal_housing_username: 'Thomas Mcinnes',
          balance: '¤400.00'
        },
        {
          code: 'INC',
          date: '01-01-2010',
          universal_housing_username: 'Gracie Barnes',
          balance: '¤500.00'
        }
      ]
    }.to_json

    stub_request(:get, 'https://example.com/tenancy/api/v1/tenancies/TEST%2F01/actions')
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end
end
