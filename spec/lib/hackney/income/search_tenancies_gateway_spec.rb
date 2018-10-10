require 'rails_helper'

describe Hackney::Income::SearchTenanciesGateway do
  let(:tenancies_results) do
    generate_fake_tennancy_results(10)
  end

  let(:number_of_pages) do
    Faker::Number.number(2).to_i
  end

  let(:tenancies_results_body) do
    { number_of_pages: number_of_pages, data: { tenancies: tenancies_results } }.to_json
  end

  let(:search_tenancies_gateway) do
    described_class.new(api_host: 'https://example.com/api/v1', api_key: 'skeleton')
  end

  let(:page) { Faker::Number.number(2).to_i }
  let(:page_size) { Faker::Number.number(2).to_i }
  let(:search_term) { Faker::Name.unique.first_name }

  let(:params) do
    {
      search_term: search_term,
      page: search_term,
      page_size: page_size
    }
  end

  let(:url_params) do
    {
      "SearchTerm": params[:search_term],
      "Page": params[:page],
      "PageSize": params[:page_size]
    }
  end

  subject do
    search_tenancies_gateway.search(params)
  end

  before do
    stub_request(:get, "https://example.com/api/v1/tenancies/search?#{URI.encode_www_form(url_params)}")
    .to_return(body: tenancies_results_body)
  end

  context 'when searching for Mrs S Smith' do
    let(:search_term) { 'Mrs S Smith' }
    let(:tenancies_results) do
      results = generate_fake_tennancy_results(3)
      results.insert(0,
                     "ref": '112345/35',
                     "prop_ref": '00015378',
                     "current_balance": {
                       "value": -15.89,
                       "currency_code": 'GBP'
                     },
                     "tenure": 'SEC',
                     "primary_contact": {
                        "name": 'Mrs S Smith                                                              ',
                        "postcode": 'G9 0RX',
                        "short_address": '6 Fake Road 99 Wot Street'
                     })
      results
    end

    it 'the returned result should be a TenancySearchResult' do
      expect(subject[:results].size).to eq(4)

      expect(subject[:results]).to all(be_instance_of(Hackney::Income::Domain::TenancySearchResult))

      expect(subject[:results].first).to have_attributes(ref: '112345/35')
      expect(subject[:results].first).to have_attributes(property_ref: '00015378')
      expect(subject[:results].first).to have_attributes(tenure: 'SEC')
      expect(subject[:results].first).to have_attributes(current_balance: -15.89)
      expect(subject[:results].first).to have_attributes(primary_contact_name: 'Mrs S Smith                                                              ')
      expect(subject[:results].first).to have_attributes(primary_contact_short_address: '6 Fake Road 99 Wot Street')
      expect(subject[:results].first).to have_attributes(primary_contact_postcode: 'G9 0RX')

      expect(subject[:number_of_pages]).to eq(number_of_pages)

      request = a_request(:get, 'https://example.com/api/v1/tenancies/search').with(
        headers: { 'X-Api-Key' => 'skeleton' },
        query: url_params
      )

      expect(request).to have_been_made
    end
  end

  context 'when searching with different params' do
    let(:page) { 10 }
    let(:page_size) { 1000 }
    let(:search_term) { 'the house by the main road' }

    it 'forwards all these params' do
      expect(subject[:results].size).to eq(10)
      expect(subject[:number_of_pages]).to eq(number_of_pages)
      expect(subject[:results]).to all(be_instance_of(Hackney::Income::Domain::TenancySearchResult))

      request = a_request(:get, 'https://example.com/api/v1/tenancies/search').with(
        headers: { 'X-Api-Key' => 'skeleton' },
        query: url_params
      )
      expect(request).to have_been_made
    end
  end

  context 'when searching for something with no results' do
    let(:tenancies_results) { [] }

    it 'should return an empty array of items' do
      expect(subject[:results]).to eq([])
      expect(subject[:number_of_pages]).to eq(number_of_pages)

      request = a_request(:get, 'https://example.com/api/v1/tenancies/search').with(
        headers: { 'X-Api-Key' => 'skeleton' },
        query: url_params
      )
      expect(request).to have_been_made
    end
  end

  context 'when there is some strange json' do
    let(:tenancies_results_body) { '{}' }

    it 'should return an empty array' do
      expect(subject[:results]).to eq([])

      request = a_request(:get, 'https://example.com/api/v1/tenancies/search').with(
        headers: { 'X-Api-Key' => 'skeleton' },
        query: url_params
      )
      expect(request).to have_been_made
    end
  end

  private

  def generate_fake_tennancy_results(number)
    results = []
    number.times do
      results << {
        "ref": "#{Faker::Number.number(6)}/#{Faker::Number.number(2)}",
        "prop_ref": Faker::Number.number(8),
        "tenure": Faker::Lorem.characters(3),
        "current_balance": {
          "value": Faker::Number.negative.round(2),
          "currency_code": 'GBP'
        },
        "primary_contact": {
          "name": "#{Faker::Name.prefix} #{Faker::Name.name}",
          "short_address": Faker::Address.street_address.to_s,
          "postcode": Faker::Address.postcode.to_s
        }
      }
    end
    results
  end
end
