require 'rails_helper'

describe 'Viewing A Letter Preview' do
  let(:uuid) { SecureRandom.uuid }
  let(:preview) { Faker::DumbAndDumber.quote }

  before do
    create_jwt_token
  end

  context 'when sending a rents letter' do
    before do
      stub_my_cases_response
      stub_get_templates_response
      stub_success_post_send_letter_response
    end

    scenario do
      given_i_am_logged_in
      when_i_visit_new_letter_page
      then_i_see_a_letter_form
    end

    scenario do
      given_i_am_logged_in
      when_i_visit_new_letter_page
      and_i_select letter_type: 'Letter 1 template'
      and_i_fill_in_the_form_and_submit
      then_i_see_the_successful_letters_ready_to_send
      and_i_see_a_send_letter_button
    end
  end

  context 'when sending a leasehold letter' do
    before do
      stub_my_cases_response
      stub_get_templates_response
      stub_success_post_send_letter_response_as_lba
    end

    scenario do
      given_i_am_logged_in
      when_i_visit_new_letter_page
      and_i_select letter_type: 'Letter before action'
      and_i_fill_in_the_form_and_submit
      then_i_cannot_send_a_letter
    end
  end

  def when_i_visit_new_letter_page
    visit letters_new_path
  end

  def then_i_see_a_letter_form
    expect(page).to have_css('h1', text: 'Send Letters', count: 1)

    expect(page).to have_field('pay_refs')
    expect(page).to have_css('span.form-hint', text: 'Enter comma separated payment references', count: 1)

    expect(page).to have_field('template_id')
    expect(page).to have_css('span.form-hint', text: 'Select a letter template to send from the dropdown list below', count: 1)
  end

  def and_i_select(letter_type:)
    select letter_type, from: 'template_id'
  end

  def and_i_fill_in_the_form_and_submit
    fill_in 'pay_refs', with: 'some_pay_ref, other_pay_ref'

    click_button 'Preview'
  end

  def then_i_see_the_successful_letters_ready_to_send
    expect(find('#successful_table')).to be_present

    success_table = find('#successful_table')
    expect(success_table.first('tr').text).not_to be_empty
    expect(success_table.first('tr')).to have_button('Send')
  end

  def and_i_see_a_send_letter_button
    expect(page).to have_button('Confirm and Send All', count: 1)
  end

  def then_i_cannot_send_a_letter
    expect(page).to_not have_button('Send')
    expect(page).to_not have_button('Confirm and Send All')
  end

  def stub_my_cases_response
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)

    response_json = File.read(Rails.root.join('spec', 'examples', 'my_cases_response.json'))
    stub_request(:get, /my-cases\?full_patch=false&is_paused=false&number_per_page=20&page_number=1&upcoming_court_dates=false&upcoming_evictions=false&user_id=/)
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end

  def stub_get_templates_response
    stub_request(:get, %r{/messages\/letters\/get_templates})
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: [
        {
          'id' => 'letter_1_template',
          'name' => 'Letter 1 template'
        },
        {
          'id' => 'letter_before_action',
          'name' => 'Letter before action'
        }
      ].to_json)
  end

  def stub_success_post_send_letter_response
    stub_request(:post, %r{/messages\/letters})
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: {
        'template' => {
          'path' => 'lib/hackney/pdf/templates/letter_1_template.erb',
          'name' => 'Letter 1 template',
          'id' => 'letter_1_template'
        },
        'preview' => preview,
        'uuid' => uuid,
        'errors' => []
      }.to_json)
  end

  def stub_success_post_send_letter_response_as_lba
    stub_request(:post, %r{/messages\/letters})
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: {
        template: { id: 'letter_before_action' },
        preview: preview,
        uuid: uuid,
        errors: []
      }.to_json)
  end
end
