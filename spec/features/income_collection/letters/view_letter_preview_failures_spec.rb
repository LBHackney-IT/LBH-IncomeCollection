require 'rails_helper'

describe 'Viewing A Letter Preview' do
  let(:uuid) { SecureRandom.uuid }
  let(:preview) { Faker::TheITCrowd.quote }
  let(:tenancy_ref) { 'some_tenancy_ref' }

  before do
    create_jwt_token

    stub_my_cases_response
    stub_get_templates_response
    stub_post_send_letter_response
  end

  scenario do
    given_i_am_logged_in
    when_visit_new_letter_page
    then_i_see_a_letter_form
    then_i_fill_in_the_form_and_submit
    then_i_see_the_letter_preview_with_errors
  end

  def when_visit_new_letter_page
    visit new_income_collection_letter_path
  end

  def then_i_see_a_letter_form
    expect(page).to have_css('h1', text: 'Send Letters', count: 1)

    expect(page).to have_field('tenancy_refs')
    expect(page).to have_css('span.form-hint', text: 'Enter comma separated tenancy references', count: 1)

    expect(page).to have_field('template_id')
    expect(page).to have_css('span.form-hint', text: 'Select a letter template to send from the dropdown list below', count: 1)
  end

  def then_i_fill_in_the_form_and_submit
    fill_in 'tenancy_refs', with: "#{tenancy_ref}, other_tenancy_ref"

    select('Income Collection Letter 1', from: 'template_id')

    click_button 'Preview'
  end

  def then_i_see_the_letter_preview_with_errors
    expect(page).to have_css('h1', text: 'Letter preview', count: 1)
    expect(page).to have_css('.letter_preview', text: preview, count: 1)
    expect(page).to have_css('th', text: 'Error Field', count: 1)
    expect(page).to have_css('th', text: 'Error Message', count: 1)
    expect(page).to have_css('td', text: 'Correspondence address 1', count: 1)
    expect(page).to have_css('td', text: 'Missing mandatory field', count: 1)
  end

  def stub_my_cases_response
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)

    response_json = File.read(Rails.root.join('spec', 'examples', 'my_cases_response.json'))
    stub_request(:get, /cases\?full_patch=false&is_paused=false&number_per_page=20&page_number=1&upcoming_court_dates=false&upcoming_evictions=false/)
      .with(headers: { 'X-Api-Key' => ENV['HACKNEY_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_get_templates_response
    stub_request(:get, %r{/messages\/letters\/get_templates})
      .with(headers: { 'X-Api-Key' => ENV['HACKNEY_API_KEY'] })
      .to_return(status: 200, body: [
        {
          'path' => 'lib/hackney/pdf/templates/income_collection_letter_1.erb',
          'name' => 'Income Collection Letter 1',
          'id' => 'income_collection_letter_1'
        }
      ].to_json)
  end

  def stub_post_send_letter_response
    stub_request(:post, %r{/messages\/letters})
      .with(headers: { 'X-Api-Key' => ENV['HACKNEY_API_KEY'] })
      .to_return(status: 200, body: {
        'template' => {
          'path' => 'lib/hackney/pdf/templates/income_collection_letter_1.erb',
          'name' => 'Income Collection Letter 1',
          'id' => 'income_collection_letter_1'
        },
        'preview' => preview,
        'uuid' => uuid,
        'errors' => [{
          'name' => 'correspondence_address_1',
          'message' => 'missing mandatory field'
        }],
        'case' => {
          'tenancy_ref' => tenancy_ref
        }
      }.to_json)
  end
end
