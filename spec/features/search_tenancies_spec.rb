require 'rails_helper'

require_relative 'page/search_page'

describe 'Search page' do
  before do
    create_jwt_token

    stub_my_cases_response
    stub_search_response
  end

  it 'should not show the search button in header' do
    page = Page::Search.new
    page.go

    expect(page.body).to_not have_css('.button--dark-grey', text: 'Search', count: 1)
  end

  it 'shows all search fields' do
    page = Page::Search.new
    page.go

    expect(page.first_name_field.visible?)
    expect(page.last_name_field.visible?)
    expect(page.address_field.visible?)
    expect(page.post_code_field.visible?)
    expect(page.tenancy_ref_field.visible?)
  end

  it 'shows results when a search is made' do
    page = Page::Search.new
    page.go

    page.search_for_tenancy '123456/89'

    expect(page).to have_content('Found 1 result')
    expect(page.results.length).to eq(1)
  end

  it 'shows error when no results found' do
    page = Page::Search.new
    page.go

    page.search_for_tenancy '9999999999999'

    expect(page).to have_content('There was no results found')
    expect(page.results.length).to eq(0)
  end

  def stub_search_response
    stub_const('Hackney::Income::SearchTenanciesGateway', Hackney::Income::StubSearchTenanciesGatewayBuilder.build_stub)
  end
end
