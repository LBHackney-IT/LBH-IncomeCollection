require 'rails_helper'

describe 'Create court case' do
  before do
    create_jwt_token

    stub_my_cases_response
    stub_income_api_show_tenancy
    stub_tenancy_api_payments
    stub_tenancy_api_contacts
    stub_tenancy_api_actions
    stub_tenancy_api_tenancy
    stub_view_agreements_response
    stub_create_court_case_response
    stub_view_court_cases_responses(responses: view_court_cases_responses)
    stub_update_court_case_response
    stub_update_court_outcome_response
  end

  scenario 'creating a new court case' do
    given_i_am_logged_in

    when_i_visit_a_tenancy_with_arrears
    then_i_should_see_the_court_case_section
    and_i_click_on_add_court_date

    then_i_should_see_add_court_date_page
    when_i_fill_in_the_court_date_and_time
    and_i_click_on_add

    then_i_should_see_the_tenancy_page
    and_i_should_see_the_success_message
    and_i_should_see_the_view_history_link
    and_i_should_see_the_court_date_and_time
    and_i_should_see_the_send_court_date_letter_button

    when_i_click_on_edit_court_date
    then_i_should_see_edit_court_date_page
    and_i_should_see_the_current_court_date_info
    when_i_fill_in_the_new_court_date_and_time
    and_i_click_on_save

    then_i_should_see_the_tenancy_page
    and_i_should_see_the_update_success_message
    and_i_should_see_the_updated_court_date_and_time
    and_i_should_see_the_send_court_date_letter_button

    when_i_click_on_add_court_outcome
    then_i_should_see_edit_court_outcome_page
    when_i_fill_in_the_court_outcome
    and_i_click_add_outcome
    then_i_should_see_the_court_case_page

    and_the_court_case_details
    then_i_should_see_add_eviction_date_button
    then_i_should_see_send_outcome_letter_button

    when_i_click_to_edit_the_court_outcome
    then_i_should_see_edit_court_outcome_page
    and_the_existing_court_outcome_details

    when_i_fill_in_the_court_outcome_with_an_adjourned_outcome
    and_i_click_add_outcome
    and_im_asked_to_select_terms_and_disrepair_counter_claim
    and_i_choose_yes_for_terms_and_no_for_disrepair_counter_claim
    and_i_click_add_outcome
    then_i_am_asked_to_select_the_payment_type_of_the_agreement
    and_i_should_see_create_agreement_page
  end

  def when_i_visit_a_tenancy_with_arrears
    visit tenancy_path(id: '1234567/01')
  end

  def then_i_should_see_the_court_case_section
    expect(page).to have_content('Court case')
    expect(page).to have_content('No valid court case at this time')
    expect(page).to have_link('Add court date')
  end

  def and_i_click_on_add_court_date
    click_link 'Add court date'
  end

  def then_i_should_see_add_court_date_page
    expect(page).to have_content('Add court date')
    expect(page).to have_content('Court date')
    expect(page).to have_content('Court hearing time')
    expect(page).to have_button('Add')
  end

  def when_i_fill_in_the_court_date_and_time
    fill_in 'court_date', with: '21/07/3000'
    fill_in 'court_time', with: '11:11'
  end

  def and_i_click_on_add
    click_button 'Add'
  end

  def then_i_should_see_the_tenancy_page
    expect(page).to have_current_path(tenancy_path(id: '1234567/01'))
  end

  def and_i_should_see_the_success_message
    expect(page).to have_content('Successfully created a new court case')
  end

  def and_i_should_see_the_view_history_link
    expect(page).to have_content('View history')
  end

  def and_i_should_see_the_court_date_and_time
    expect(page).to have_content('Court date: July 21st, 3000 at 11:11')
  end

  def and_i_should_see_the_send_court_date_letter_button
    expect(page).to have_button('Send court date letter')
  end

  def when_i_click_on_edit_court_date
    click_link 'Edit court date'
  end

  def then_i_should_see_edit_court_date_page
    expect(page).to have_content('Edit court date')
    expect(page).to have_content('Court date')
    expect(page).to have_content('Court hearing time')
    expect(page).to have_button('Save')
  end

  def and_i_should_see_the_current_court_date_info
    expect(find_field('court_date').value).to eq('3000-07-21')
    expect(find_field('court_time').value).to eq('11:11')
  end

  def when_i_fill_in_the_new_court_date_and_time
    fill_in 'court_date', with: '23/07/3000'
    fill_in 'court_time', with: '12:34'
  end

  def and_i_click_on_save
    click_button 'Save'
  end

  def and_i_should_see_the_update_success_message
    expect(page).to have_content('Successfully updated the court case')
  end

  def and_i_should_see_the_updated_court_date_and_time
    expect(page).to have_content('Court date: July 23rd, 3000 at 12:34')
  end

  def when_i_click_on_add_court_outcome
    click_link 'Add court outcome'
  end

  def then_i_should_see_edit_court_outcome_page
    expect(page).to have_content('Add court outcome')
    expect(page).to have_content('Court outcome')
    expect(page).to have_content('What was the outcome from court?')
    expect(page).to have_content('Balance on court outcome date')
    expect(page).to have_content('Strike out date (optional)')
  end

  def when_i_fill_in_the_court_outcome
    choose('court_outcome_OPD')
    fill_in 'balance_on_court_outcome_date', with: '1000'
    fill_in 'strike_out_date', with: '10/07/3024'
  end

  def and_i_click_add_outcome
    click_button 'Add outcome'
  end

  def then_i_should_see_the_court_case_page
    expect(page).to have_content('Court case')
    expect(page).to have_content('Alan Sugar')
    expect(page).to have_content('Edit court date')
    expect(page).to have_content('Edit court outcome')
  end

  def and_the_court_case_details
    expect(page).to have_content('Court date')
    expect(page).to have_content('July 23rd, 3000 at 12:34')
    expect(page).to have_content('Court outcome:')
    expect(page).to have_content('Outright Possession (with Date)')
    expect(page).to have_content('Strike out date:')
    expect(page).to have_content('July 10th, 3024')
    expect(page).to have_content('Balance on court date:')
    expect(page).to have_content('£1,000')
  end

  def then_i_should_see_add_eviction_date_button
    expect(page).to have_content('Add an eviction date')
  end

  def then_i_should_see_send_outcome_letter_button
    expect(page).to have_button('Send court outcome confirmation letter')
  end

  def when_i_click_to_edit_the_court_outcome
    click_link 'Edit court outcome'
  end

  def and_the_existing_court_outcome_details
    expect(find_field('court_outcome_OPD')).to be_checked
    expect(find_field('strike_out_date').value).to eq('3024-07-10')
    expect(find_field('balance_on_court_outcome_date').value).to eq('1000')
  end

  def when_i_fill_in_the_court_outcome_with_an_adjourned_outcome
    choose('court_outcome_AGP')
    fill_in 'balance_on_court_outcome_date', with: '1500'
    fill_in 'strike_out_date', with: '10/08/3025'
  end

  def and_im_asked_to_select_terms_and_disrepair_counter_claim
    expect(page).to have_content('Terms and disrepair counter claim')
    expect(page).to have_content('Are there terms?')
    expect(page).to have_content('Is there a disrepair counter claim?')
  end

  def and_i_choose_yes_for_terms_and_no_for_disrepair_counter_claim
    choose('terms_Yes')
    choose('disrepair_counter_claim_No')
  end

  def then_i_am_asked_to_select_the_payment_type_of_the_agreement
    choose('payment_type_regular')
    click_button 'Continue'
  end

  def and_i_should_see_create_agreement_page
    expect(page).to have_content('Create court agreement')
    expect(page).to have_content('Agreement for: Alan Sugar')
    expect(page).to have_content('Court case related to this agreement')
    expect(page).to have_content('Court date: July 23rd, 3000')
    expect(page).to have_content('Court outcome: Adjourned generally with permission to restore')
    expect(page).to have_content('Frequency of payments')
    expect(page).to have_content('Weekly instalment amount')
    expect(page).to have_content('Start date')
    expect(page).to have_content('End date')
    expect(page).to have_content('Notes')
  end

  def stub_my_cases_response
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)

    response_json = File.read(Rails.root.join('spec', 'examples', 'my_cases_response.json'))
    stub_request(:get, /cases\?full_patch=false&is_paused=false&number_per_page=20&page_number=1&upcoming_court_dates=false&upcoming_evictions=false/)
      .with(headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_create_court_case_response
    request_body_json = {
      court_date: '21/07/3000 11:11',
      court_outcome: nil,
      balance_on_court_outcome_date: nil,
      strike_out_date: nil,
      terms: nil,
      disrepair_counter_claim: nil
    }.to_json

    response_json = {
      id: 12,
      tenancyRef: '1234567/01',
      courtDate: '21/07/3000 11:11',
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

  def stub_update_court_case_response
    request_body_json = {
      court_date: '23/07/3000 12:34',
      court_outcome: nil,
      balance_on_court_outcome_date: nil,
      strike_out_date: nil,
      terms: nil,
      disrepair_counter_claim: nil,
      username: nil
    }.to_json

    stub_request(:patch, 'https://example.com/income/api/v1/court_case/12/update')
         .with(
           body: request_body_json,
           headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] }
         )
         .to_return(status: 200, headers: {})
  end

  def stub_update_court_outcome_response
    request_body_jsons = [
      {
        court_date: nil,
        court_outcome: 'OPD',
        balance_on_court_outcome_date: '1000',
        strike_out_date: '10/07/3024',
        terms: nil,
        disrepair_counter_claim: nil,
        username: 'Hackney User'
      }.to_json,
      {
        court_date: nil,
        court_outcome: 'AGP',
        balance_on_court_outcome_date: '1500',
        strike_out_date: '10/08/3025',
        terms: true,
        disrepair_counter_claim: false,
        username: 'Hackney User'
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
      courtCases:
        [{
          id: 12,
          tenancyRef: '1234567/01',
          courtDate: '21/07/3000 11:11',
          courtOutcome: nil,
          balanceOnCourtOutcomeDate: nil,
          strikeOutDate: nil,
          terms: nil,
          disrepairCounterClaim: nil
        }]
}.to_json

    updated_court_case_response_json = {
      courtCases:
        [{
          id: 12,
          tenancyRef: '1234567/01',
          courtDate: '23/07/3000 12:34',
          courtOutcome: nil,
          balanceOnCourtOutcomeDate: nil,
          strikeOutDate: nil,
          terms: nil,
          disrepairCounterClaim: nil
        }]
    }.to_json

    court_case_with_court_outcome_response_json = {
      courtCases:
        [{
          id: 12,
          tenancyRef: '1234567/01',
          courtDate: '23/07/3000 12:34',
          courtOutcome: 'OPD',
          balanceOnCourtOutcomeDate: '1000',
          strikeOutDate: '10/07/3024',
          terms: nil,
          disrepairCounterClaim: nil
        }]
    }.to_json

    court_case_with_court_outcome_and_terms_response_json = {
      courtCases:
        [{
          id: 12,
          tenancyRef: '1234567/01',
          courtDate: '23/07/3000 12:34',
          courtOutcome: 'AGP',
          balanceOnCourtOutcomeDate: '1500',
          strikeOutDate: '10/08/3025',
          terms: true,
          disrepairCounterClaim: false
        }]
    }.to_json

    [no_court_cases_response_json,
     one_court_case_response_json,
     one_court_case_response_json,
     updated_court_case_response_json,
     court_case_with_court_outcome_response_json,
     court_case_with_court_outcome_response_json,
     court_case_with_court_outcome_response_json,
     court_case_with_court_outcome_and_terms_response_json]
  end
end
