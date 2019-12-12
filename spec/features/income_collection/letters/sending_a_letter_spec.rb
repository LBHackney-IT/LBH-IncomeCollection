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
  end

  scenario 'Sending a letter'do
    given_i_am_logged_in
    when_i_visit_the_homepage
    then_i_should_see_cases_assigned_to_me
    i_then_click_on_a_case
    i_then_visit_income_collection_letters
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
    visit income_collection_letters_path
    # expect(page).to have_content('Send Letter One')
    # click_link 'Send Letter One'
    # # Because the case probz hasnt got classification of send letter one?
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
