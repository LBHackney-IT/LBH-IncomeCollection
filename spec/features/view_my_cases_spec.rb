require 'rails_helper'

require_relative 'page/worktray_page'

describe 'Viewing My Cases' do
  around { |example| with_mock_authentication { example.run } }

  before do
    stub_my_cases_response
    stub_my_cases_response(is_paused: true)
    stub_my_cases_response(recommended_actions: 'no_action')
    stub_my_cases_response(patch: 'E01')
    stub_my_cases_response(is_paused: true, patch: 'E01')
  end

  scenario do
    given_i_am_logged_in
    when_i_visit_the_homepage
    then_i_should_see_a_phase_banner
    then_i_should_see_a_search_button
    then_i_should_see_cases_assigned_to_me
  end

  scenario do
    given_i_am_logged_in
    when_i_visit_the_homepage
    i_should_see_all_of_the_tabs
    when_i_click_on_the_paused_tab
    then_i_should_see_paused_cases
  end

  scenario do
    given_i_am_logged_in
    when_i_visit_the_homepage
    i_should_see_all_of_the_tabs
    then_i_should_filter_worktray_by_an_action
  end

  scenario do
    given_i_am_logged_in
    when_i_visit_the_homepage
    i_should_see_all_of_the_tabs
    then_i_should_filter_worktray_by_patch
    when_i_click_on_the_paused_tab
    then_i_see_the_patch_is_still_selected
  end

  def given_i_am_logged_in
    visit '/auth/azureactivedirectory'
  end

  def when_i_visit_the_homepage
    visit '/'
  end

  def i_should_see_all_of_the_tabs
    expect(page).to have_link(href: '/worktray')
    expect(page).to have_link(href: '/worktray?paused=true')
    expect(page).to have_link(href: '/worktray?full_patch=true')
    # expect(page).to have_link(href: '/worktray?upcoming_court_dates=true')
    # expect(page).to have_link(href: '/worktray?upcoming_evictions=true')
  end

  def when_i_click_on_the_paused_tab
    page = Page::Worktray.new
    page.click_paused_tab!
  end

  def then_i_should_see_paused_cases
    page = Page::Worktray.new
    expect(page).to have_field('paused_tab', checked: true)
    expect(page.results.length).to eq(2)
  end

  def then_i_should_filter_worktray_by_patch
    expect(page).to have_field('patch_code')
    select('Arrears East Patch 1', from: 'patch_code')
    click_button 'Filter by patch'
  end

  def then_i_should_see_cases_assigned_to_me
    expect(page.body).to have_css('h2', text: 'Your Worktray', count: 1)
    expect(page).to have_field('immediateactions_tab', checked: true)
    expect(page.body).to have_content('TEST/01')
    expect(page.body).to have_content('TEST/02')
  end

  def then_i_should_see_a_phase_banner
    expect(page.body).to have_css('.phase-tag', text: 'BETA', count: 1)
    expect(page.body).to have_css('.phase-banner span', text: 'This is a new service - your feedback will help us to improve it.', count: 1)
  end

  def then_i_should_see_a_search_button
    expect(page.body).to have_css('.button--dark-grey', text: 'Search', count: 1)
    expect(page).to have_link(href: '/search')
  end

  def then_i_should_filter_worktray_by_an_action
    visit '/worktray'
    select('No Action', from: 'recommended_actions')
    click_button 'Filter by next action'
  end

  def then_i_see_the_patch_is_still_selected
    expect(page.body).to have_css('option[selected]', text: 'Arrears East Patch 1')
  end

  def stub_my_cases_response(override_params = {})
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)

    response_json = File.read(Rails.root.join('spec', 'examples', 'my_cases_response.json'))

    default_filters = {
      is_paused: false,
      number_per_page: 20,
      page_number: 1,
      full_patch: false,
      patch: nil,
      recommended_actions: nil,
      upcoming_court_dates: false,
      upcoming_evictions: false,
      user_id: ''
    }.merge(override_params).reject { |_k, v| v.nil? }

    uri = /my-cases\?#{default_filters.to_param}/

    stub_request(:get, uri)
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end
end
