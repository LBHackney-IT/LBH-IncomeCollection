require 'rails_helper'

require_relative 'page/worktray_page'

describe 'Viewing My Cases' do
  around { |example| with_mock_authentication { example.run } }

  before do
    stub_my_cases_response
    stub_my_paused_cases_response
  end

  scenario do
    given_i_am_logged_in
    when_i_visit_the_homepage
    then_i_should_see_a_phase_banner
    then_i_should_see_cases_assigned_to_me
  end

  scenario do
    given_i_am_logged_in
    when_i_visit_the_homepage
    when_i_click_on_the_paused_tab
    then_i_should_see_paused_cases
  end

  def given_i_am_logged_in
    visit '/auth/azureactivedirectory'
  end

  def when_i_visit_the_homepage
    visit '/'
  end

  def when_i_click_on_the_paused_tab
    page = Page::Worktray.new
    page.click_paused_tab!
  end

  def then_i_should_see_paused_cases
    page = Page::Worktray.new
    expect(page).to have_field('tab2', checked: true)
    expect(page.results.length).to eq(1)
  end

  def then_i_should_see_cases_assigned_to_me
    expect(page.body).to have_css('h2', text: 'Your Worktray', count: 1)
    expect(page).to have_field('tab1', checked: true)
    expect(page.body).to have_content('TEST/01')
    expect(page.body).to have_content('TEST/02')
  end

  def then_i_should_see_a_phase_banner
    expect(page.body).to have_css('.phase-tag', text: 'BETA', count: 1)
    expect(page.body).to have_css('.phase-banner span', text: 'This is a new service - your feedback will help us to improve it.', count: 1)
  end

  def stub_my_cases_response
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)

    response_json = File.read(Rails.root.join('spec', 'fixtures', 'my_cases_response.json'))
    stub_request(:get, /my-cases\?is_paused=false&number_per_page=20&page_number=1&user_id=/)
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_my_paused_cases_response
    stub_request(:get, /my-cases\?is_paused=true&number_per_page=20&page_number=1&user_id=/)
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: SINGLE_CASE_RESPONCE)
  end

  SINGLE_CASE_RESPONCE = <<-JSON_RESPONCE.freeze
    { "cases": [ {
            "active_agreement": false,
            "active_agreement_contribution": 0.0,
            "active_nosp": false,
            "active_nosp_contribution": 0.0,
            "balance": "0.0",
            "balance_contribution": 0.0,
            "broken_court_order": false,
            "broken_court_order_contribution": 0.0,
            "current_arrears_agreement_status": 0,
            "current_balance": "¤988.43",
            "days_in_arrears": 0,
            "days_in_arrears_contribution": 0.0,
            "days_since_last_payment": 0,
            "days_since_last_payment_contribution": 0.0,
            "latest_action": {
                "code": "GEN",
                "date": "2018-07-16T16:22:00.000Z"
            },
            "nosp_served": false,
            "nosp_served_contribution": 0.0,
            "number_of_broken_agreements": 0,
            "number_of_broken_agreements_contribution": 0.0,
            "payment_amount_delta": 0,
            "payment_amount_delta_contribution": 0.0,
            "payment_date_delta": 0,
            "payment_date_delta_contribution": 0.0,
            "primary_contact": {
                "name": "Miss S Test                                                           ",
                "postcode": "A1 123",
                "short_address": "Test Address"
            },
            "priority_band": "green",
            "priority_score": "0.0",
            "ref": "TEST/01"
        }
    ],
    "number_of_pages": 1
    }
  JSON_RESPONCE
end
