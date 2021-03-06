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
    FeatureFlag.deactivate('test_flag')
  end

  def when_i_visit_the_feature_flags_dashboard
    visit feature_flags_dashboard_path
  end

  def then_i_should_see_the_existing_feature_flag
    expect(page).to have_content 'Test flag Disabled'
  end

  def when_i_activate_the_feature
    click_button 'Activate Test flag'
  end

  def then_the_feature_is_activated
    expect(page).to have_content 'Test flag Enabled'
    expect(FeatureFlag.active?('test_flag')).to be true
  end

  def when_i_deactivate_the_feature
    click_button 'Deactivate Test flag'
  end

  def then_the_feature_is_deactivated
    expect(page).to have_content 'Test flag Disabled'
    expect(FeatureFlag.active?('test_flag')).to be false
  end
end
