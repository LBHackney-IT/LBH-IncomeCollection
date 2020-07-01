require 'rails_helper'

describe Hackney::Income::CreateAgreementGateway do
  subject { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }

  let(:request_params) do
    {
      tenancy_ref: Faker::Lorem.characters(number: 6),
      agreement_type: 'informal',
      frequency: %w[weekly monthly].sample,
      amount: Faker::Commerce.price(range: 10...100),
      start_date: Faker::Date.between(from: 2.days.ago, to: Date.today),
      created_by: Faker::Name.name
    }
  end

  let(:json_request_body) do
    {
      agreement_type: request_params.fetch(:agreement_type),
      frequency: request_params.fetch(:frequency),
      amount: request_params.fetch(:amount),
      start_date: request_params.fetch(:start_date),
      created_by: request_params.fetch(:created_by)
    }.to_json
  end

  context 'when sending a successful request to the API' do
    before do
      stub_request(:post, "https://example.com/api/v1/agreement/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/")
        .to_return(
          status: 200
        )
    end

    it 'should send the required params' do
      subject.create_agreement(**request_params)

      assert_requested(
        :post,
        "https://example.com/api/v1/agreement/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/",
        headers: { 'Content-Type': 'application/json', 'X-Api-Key': 'skeleton' },
        body: json_request_body,
        times: 1
      )
    end
  end

  context 'when receiving a 500 error from the API' do
    before do
      stub_request(:post, "https://example.com/api/v1/agreement/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/")
        .to_return(
          status: 500
        )
    end

    it 'should raise and error' do
      expect do
        subject.create_agreement(**request_params)
      end.to raise_error(
        Exceptions::IncomeApiError,
        "[Income API error: Received 500 response] when trying to create a new agreement using 'https://example.com/api/v1/agreement/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/'"
      )
      assert_requested(
        :post,
        "https://example.com/api/v1/agreement/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/",
        headers: { 'Content-Type': 'application/json', 'X-Api-Key': 'skeleton' },
        body: json_request_body,
        times: 1
      )
    end
  end
end
