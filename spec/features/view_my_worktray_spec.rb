require 'rails_helper'

require_relative 'page/worktray_page'

describe 'Worktray' do
  before do
    create_jwt_token

    stub_my_cases_response
    stub_my_cases_response(is_paused: true)
    stub_my_cases_response(upcoming_court_dates: true)
    stub_my_cases_response(upcoming_evictions: true)
    stub_my_cases_response(recommended_actions: 'no_action')
    stub_my_cases_response(patch: 'E01')
    stub_my_cases_response(is_paused: true, patch: 'E01')
    stub_my_cases_response(page_number: 2)
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

  scenario 'persisting patch filter between tabs' do
    given_i_am_logged_in
    when_i_visit_the_homepage
    i_should_see_all_of_the_tabs
    then_i_should_filter_worktray_by_patch
    when_i_click_on_the_paused_tab
    then_i_see_the_patch_is_still_selected
  end

  scenario 'persisting all worktray filters between pages' do
    given_i_am_logged_in
    when_i_visit_the_homepage
    when_i_click_on_the_paused_tab
    when_i_visit_the_homepage
    then_i_should_see_paused_cases

    when_i_click_on_the_upcoming_court_dates_tab
    and_i_visit_the_homepage
    then_i_should_see_the_upcoming_court_dates_tab

    when_i_click_on_the_immediate_actions_tab
    and_i_visit_the_homepage
    then_i_should_see_immediate_actions_tab
  end

  scenario 'Pagination' do
    given_i_am_logged_in
    when_i_visit_the_homepage
    then_i_click_next_on_the_pagination
    then_the_url_should_on_page_2
    then_there_should_be_cases_in_the_table
  end

  scenario 'Visiting the upcoming court dates tab' do
    given_i_am_logged_in
    when_i_click_on_the_upcoming_court_dates_tab
    i_should_see_the_courtdate_column_with_a_readable_date
  end

  scenario 'Visiting the upcoming evictions dates tab' do
    given_i_am_logged_in
    when_i_click_on_the_upcoming_eviction_dates_tab
    i_should_see_the_evictions_column_with_a_readable_date
  end

  scenario 'Filtering Paused Cases' do
    stub_my_cases_response(is_paused: true, pause_reason: 'Missing Data')

    given_i_am_logged_in
    when_i_click_on_the_paused_tab
    when_i_filter_to_missing_data
    then_there_should_be_cases_in_the_table
  end

  def when_i_visit_the_homepage
    visit '/'
  end

  def and_i_visit_the_homepage
    when_i_visit_the_homepage
  end

  def i_should_see_all_of_the_tabs
    expect(page).to have_link(href: '/worktray?immediate_actions=true')
    expect(page).to have_link(href: '/worktray?paused=true')
    expect(page).to have_link(href: '/worktray?full_patch=true')
    expect(page).to have_link(href: '/worktray?upcoming_court_dates=true')
    expect(page).to have_link(href: '/worktray?upcoming_evictions=true')
  end

  def when_i_click_on_the_paused_tab
    page = Page::Worktray.new
    page.click_paused_tab!
  end

  def when_i_click_on_the_immediate_actions_tab
    click_link 'Immediate Actions'
  end

  def when_i_click_on_the_upcoming_court_dates_tab
    click_link 'Upcoming Court Dates'
  end

  def when_i_click_on_the_upcoming_court_dates_tab
    visit '/worktray?upcoming_court_dates=true'
    expect(page).to have_field('upcomingcourtdates_tab', checked: true)
  end

  def i_should_see_the_courtdate_column_with_a_readable_date
    expect(page).to have_content('Upcoming Court Dates')
    expect(page).to have_content('September 10th, 2030')
  end

  def when_i_click_on_the_upcoming_eviction_dates_tab
    visit '/worktray?upcoming_evictions=true'
    expect(page).to have_field('upcomingevictions_tab', checked: true)
  end

  def i_should_see_the_evictions_column_with_a_readable_date
    expect(page).to have_content('Upcoming Eviction Dates')
    expect(page).to have_content('September 10th, 2045')
  end

  def then_i_should_see_paused_cases
    page = Page::Worktray.new
    expect(page).to have_field('paused_tab', checked: true)
    expect(page.results.length).to eq(2)
  end

  def then_i_should_see_the_upcoming_court_dates_tab
    page = Page::Worktray.new
    expect(page).to have_field('upcomingcourtdates_tab', checked: true)
    expect(page.results.length).to eq(2)
  end

  def then_i_should_see_immediate_actions_tab
    page = Page::Worktray.new
    expect(page).to have_field('immediateactions_tab', checked: true)
    expect(page.results.length).to eq(2)
  end

  def then_i_should_filter_worktray_by_patch
    expect(page).to have_field('patch_code')
    select('Arrears East Patch 1', from: 'patch_code')
    click_button 'Filter by patch'
  end

  def then_i_should_see_cases_assigned_to_me
    expect(page.body).to have_css('h1', text: 'Your Worktray', count: 1)
    expect(page).to have_field('immediateactions_tab', checked: true)
    expect(page.body).to have_content('TEST/01')
    expect(page.body).to have_content('TEST/02')
  end

  def then_i_should_see_a_phase_banner
    expect(page.body).to have_css('.phase-tag', text: 'BETA', count: 1)
    expect(page.body).to have_css('.phase-banner span', text: 'This is a new service - your feedback (opens a new tab) will help us to improve it.', count: 1)
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

  def then_i_click_next_on_the_pagination
    click_link 'Next ›'
  end

  def then_the_url_should_on_page_2
    expect(page.driver.current_url).to match(/page=2/)
  end

  def then_there_should_be_cases_in_the_table
    expect(page.body).to have_css('.tenancy_list tbody tr', count: 2)
  end

  def when_i_filter_to_missing_data
    select('Missing Data', from: 'pause_reason')
    click_button 'Filter by pause reason'
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
      upcoming_evictions: false
    }.merge(override_params).reject { |_k, v| v.nil? }

    uri = /cases\?#{default_filters.to_param.gsub('+', '%20')}/

    stub_request(:get, uri)
      .with(headers: { 'X-Api-Key' => ENV['INCOME_API_KEY'] })
      .to_return(status: 200, body: response_json)
  end
end
