require 'rails_helper'

describe 'Viewing A Letter Preview' do
  around { |example| with_mock_authentication { example.run } }

  before do
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

  def given_i_am_logged_in
    visit '/auth/azureactivedirectory'
  end

  def when_visit_new_letter_page
    visit letters_new_path
  end

  def then_i_see_a_letter_form
    expect(page.body).to have_css('h1', text: 'Send Letters', count: 1)

    expect(page).to have_field('pay_ref')
    expect(page).to have_field('template_id')
  end

  def then_i_fill_in_the_form_and_submit
    fill_in 'pay_ref', with: 'some_pay_ref'

    select('Letter 1 template', from: 'template_id')

    click_button 'Preview'
  end

  def then_i_see_the_letter_preview_with_errors
    expect(page.body).to have_css('h1', text: 'Letter preview', count: 1)
    expect(page).to have_css('.letter_preview', text: 'Letter letter letter', count: 1)
    expect(page).to have_css('th', text: 'Error Field', count: 1)
    expect(page).to have_css('th', text: 'Error Message', count: 1)
    expect(page).to have_css('td', text: 'Correspondence address 1', count: 1)
    expect(page).to have_css('td', text: 'Missing mandatory field', count: 1)
  end

  def stub_my_cases_response
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)

    response_json = File.read(Rails.root.join('spec', 'examples', 'my_cases_response.json'))
    stub_request(:get, /my-cases\?is_paused=false&number_per_page=20&page_number=1&user_id=/)
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_get_templates_response
    stub_request(:get, %r{/pdf\/get_templates})
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: [
        {
          'path' => 'lib/hackney/pdf/templates/letter_1_template.erb',
          'name' => 'Letter 1 template',
          'id' => 'letter_1_template'
        }
      ].to_json)
  end

  def stub_post_send_letter_response
    stub_request(:post, %r{/pdf\/send_letter})
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: {
        'template' => {
          'path' => 'lib/hackney/pdf/templates/letter_1_template.erb',
          'name' => 'Letter 1 template',
          'id' => 'letter_1_template'
        },
        'preview' => 'Letter letter letter',
        'errors' => [{
          'field' => 'correspondence_address_1',
          'error' => 'missing mandatory field'
        }]
      }.to_json)
  end
end
