require 'rails_helper'

describe 'Viewing A Letter Preview' do
  let(:uuid) { SecureRandom.uuid }
  let(:preview) { Faker::TvShows::TheITCrowd.quote }
  let(:tenancy_ref) { 'some_tenancy_ref' }
  let(:document_id) { Faker::Number.number }

  before do
    create_jwt_token
  end

  context 'when sending a rents letter' do
    before do
      stub_my_cases_response
      stub_get_templates_response

      given_i_am_logged_in
      when_i_visit_new_letter_page
    end

    scenario do
      then_i_see_a_letter_form
    end

    scenario 'HTML Preview' do
      stub_success_post_send_letter_response(with_doc: false)

      and_i_select letter_type: 'Income Collection Letter 1'
      and_i_fill_in_the_form_and_submit
      then_i_see_the_successful_letters_ready_to_send
      and_there_is_a_html_preview_element
      and_i_see_a_send_letter_button
    end

    scenario 'PDF Preview' do
      stub_success_post_send_letter_response(with_doc: true)

      and_i_select letter_type: 'Income Collection Letter 1'
      and_i_fill_in_the_form_and_submit
      then_i_see_the_successful_letters_ready_to_send
      and_there_is_a_pdf_object_visible_on_the_page
      and_i_see_a_send_letter_button
    end
  end

  def when_i_visit_new_letter_page
    visit new_income_collection_letter_path
  end

  def then_i_see_a_letter_form
    expect(page).to have_css('h1', text: 'Send Letters', count: 1)

    expect(page).to have_field('tenancy_refs')
    expect(page).to have_css('span.form-hint', text: 'Enter comma separated tenancy references', count: 1)

    expect(page).to have_field('template_id')
    expect(page).to have_css('span.form-hint', text: 'Select a letter template to send from the dropdown list below', count: 1)
  end

  def and_i_select(letter_type:)
    select letter_type, from: 'template_id'
  end

  def and_i_fill_in_the_form_and_submit
    fill_in 'tenancy_refs', with: "#{tenancy_ref}, other_tenancy_ref"

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

  def and_there_is_a_html_preview_element
    expect(page).to have_css('div.letter_preview', text: preview)
  end

  def and_there_is_a_pdf_object_visible_on_the_page
    expect(page).to have_css("object#preview-doc-#{document_id}[type='application/pdf'][data='#{document_path(document_id)}.pdf?inline=true&documents_view=true']")
  end

  def stub_get_templates_response
    stub_request(:get, %r{/messages\/letters\/get_templates})
      .with(headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] })
      .to_return(status: 200, body: [
        {
          'id' => 'income_collection_letter_1_template',
          'name' => 'Income Collection Letter 1'
        },
        {
          'id' => 'letter_before_action',
          'name' => 'Letter before action'
        }
      ].to_json)
  end

  def stub_success_post_send_letter_response(with_doc:)
    stub_request(:post, %r{/messages\/letters})
      .with(headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] })
      .to_return(status: 200, body: {
        'template' => {
          'path' => 'lib/hackney/pdf/templates/income_collection_letter_1_template.erb',
          'name' => 'Income Collection Letter 1',
          'id' => 'income_collection_letter_1_template'
        },
        'preview' => preview,
        'uuid' => uuid,
        'document_id': (with_doc ? document_id : nil),
        'errors' => [],
        'case' => {
          'tenancy_ref' => tenancy_ref
        }
      }.to_json)
  end
end
