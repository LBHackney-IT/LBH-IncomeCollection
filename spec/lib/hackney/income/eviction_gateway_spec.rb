require 'rails_helper'

describe Hackney::Income::EvictionGateway do
  subject { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }
  let(:tenancy_ref) { "#{Faker::Lorem.characters(number: 6)}/#{Faker::Lorem.characters(number: 2)}" }
  let(:username) { Faker::TvShows::StrangerThings.character }

  describe '#create_eviction' do
    let(:request_params) do
      {
          tenancy_ref: tenancy_ref,
          date: Faker::Date.between(from: 5.days.ago, to: Date.today)
      }
    end

    let(:json_request_body) do
      {
          date: request_params.fetch(:date),
          username: username
      }.to_json
    end

    context 'when sending a successful request to the API' do
      before do
        stub_request(:post, "https://example.com/api/v1/eviction/#{ERB::Util.url_encode(tenancy_ref)}/")
            .to_return(
              status: 200
            )
      end

      it 'should send the required params' do
        subject.create_eviction(params: request_params, username: username)

        assert_requested(
          :post,
          "https://example.com/api/v1/eviction/#{ERB::Util.url_encode(tenancy_ref)}/",
          headers: { 'Content-Type': 'application/json', 'X-Api-Key': 'skeleton' },
          body: json_request_body,
          times: 1
        )
      end
    end

    context 'when receiving a 500 error from the API' do
      before do
        stub_request(:post, "https://example.com/api/v1/eviction/#{ERB::Util.url_encode(tenancy_ref)}/")
            .to_return(
              status: 500
            )
      end

      it 'should raise and error' do
        expect do
          subject.create_eviction(params: request_params, username: username)
        end.to raise_error(
          Exceptions::IncomeApiError,
          "[Income API error: Received 500 response] when trying to create a new eviction date using 'https://example.com/api/v1/eviction/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/'"
        )
        assert_requested(
          :post,
          "https://example.com/api/v1/eviction/#{ERB::Util.url_encode(tenancy_ref)}/",
          headers: { 'Content-Type': 'application/json', 'X-Api-Key': 'skeleton' },
          body: json_request_body,
          times: 1
        )
      end
    end
  end
end
