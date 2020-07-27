require 'rails_helper'

describe 'Feature flags' do
  before do
    create_jwt_token

    stub_my_cases_response
  end

  scenario 'manage feature flags' do
    given_i_am_logged_in
    and_there_is_a_feature_flag

    when_i_visit_the_feature_flags_dashboard
    then_i_should_see_the_existing_feature_flag

    when_i_activate_the_feature
    then_the_feature_is_activated

    when_i_deactivate_the_feature
    then_the_feature_is_deactivated
  end

  def and_there_is_a_feature_flag
    FeatureFlag.deactivate('create_informal_agreements')
    FeatureFlag.deactivate('create_formal_agreements')
  end

  def when_i_visit_the_feature_flags_dashboard
    visit feature_flags_dashboard_path
  end

  def then_i_should_see_the_existing_feature_flag
    expect(page).to have_content 'Create informal agreements Disabled'
    expect(page).to have_content 'Create formal agreements Disabled'

  end

  def when_i_activate_the_feature
    click_button 'Activate Create informal agreements'
    click_button 'Activate Create formal agreements'
  end

  def then_the_feature_is_activated
    expect(page).to have_content 'Create informal agreements Enabled'
    expect(FeatureFlag.active?('create_informal_agreements')).to be true

    expect(page).to have_content 'Create formal agreements Enabled'
    expect(FeatureFlag.active?('create_formal_agreements')).to be true
  end

  def when_i_deactivate_the_feature
    click_button 'Deactivate Create informal agreements'
    click_button 'Deactivate Create formal agreements'
  end

  def then_the_feature_is_deactivated
    expect(page).to have_content 'Create informal agreements Disabled'
    expect(FeatureFlag.active?('create_informal_agreements')).to be false

    expect(page).to have_content 'Create formal agreements Disabled'
    expect(FeatureFlag.active?('create_formal_agreements')).to be false
  end

  def stub_my_cases_response
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)
    stub_const('Hackney::Income::GetActionDiaryEntriesGateway', Hackney::Income::StubGetActionDiaryEntriesGateway)
    response_json = File.read(Rails.root.join('spec', 'examples', 'my_cases_response.json'))
    stub_request(:get, /cases\?full_patch=false&is_paused=false&number_per_page=20&page_number=1&upcoming_court_dates=false&upcoming_evictions=false/)
      .with(headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end
end
