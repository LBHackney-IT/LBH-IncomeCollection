require 'rails_helper'

require_relative 'page/search_page'

describe 'Search page' do
  around { |example| with_mock_authentication { example.run } }

  before do
    stub_my_cases_response
    stub_search_response
  end

  it 'shows results when a search is made' do
    page = Pages::Search.new
    page.go

    expect(page.search_field.visible?)

    page.search_for '123456/89'

    expect(page).to have_content('Found 1 result')
    expect(page.results.length).to eq(1)
  end

  it 'shows error when no results found' do
    page = Pages::Search.new
    page.go

    expect(page.search_field.visible?)

    page.search_for '9999999999999'

    expect(page).to have_content('There was no results found')
    expect(page.results.length).to eq(0)
  end

  def stub_my_cases_response
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)

    response_json = File.read(Rails.root.join('spec', 'fixtures', 'my_cases_response.json'))
    stub_request(:get, /my-cases/)
    .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
    .to_return(status: 200, body: response_json, headers: {})
  end

  def stub_search_response
    stub_const('Hackney::Income::SearchTenanciesGateway', Hackney::Income::StubSearchTenanciesGatewayBuilder.build_stub)
  end
end
