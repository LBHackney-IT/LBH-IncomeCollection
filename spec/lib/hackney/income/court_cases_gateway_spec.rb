require 'rails_helper'

describe Hackney::Income::CourtCasesGateway do
  subject { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }

  describe '#create_court_case' do
    let(:request_params) do
      {
        tenancy_ref: Faker::Lorem.characters(number: 6),
        date_of_court_decision: Faker::Date.between(from: 5.days.ago, to: Date.today),
        court_outcome: Faker::ChuckNorris.fact,
        balance_on_court_outcome_date: Faker::Commerce.price(range: 10...100),
        strike_out_date: Faker::Date.forward(days: 365),
        created_by: Faker::Name.name
      }
    end

    let(:json_request_body) do
      {
        court_decision_date: request_params.fetch(:date_of_court_decision),
        court_outcome: request_params.fetch(:court_outcome),
        balance_at_outcome_date: request_params.fetch(:balance_on_court_outcome_date),
        strike_out_date: request_params.fetch(:strike_out_date),
        created_by: request_params.fetch(:created_by)
      }.to_json
    end

    context 'when sending a successful request to the API' do
      before do
        stub_request(:post, "https://example.com/api/v1/court_case/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/")
          .to_return(
            status: 200
          )
      end

      it 'should send the required params' do
        subject.create_court_case(**request_params)

        assert_requested(
          :post,
          "https://example.com/api/v1/court_case/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/",
          headers: { 'Content-Type': 'application/json', 'X-Api-Key': 'skeleton' },
          body: json_request_body,
          times: 1
        )
      end
    end

    context 'when receiving a 500 error from the API' do
      before do
        stub_request(:post, "https://example.com/api/v1/court_case/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/")
          .to_return(
            status: 500
          )
      end

      it 'should raise and error' do
        expect do
          subject.create_court_case(**request_params)
        end.to raise_error(
          Exceptions::IncomeApiError,
          "[Income API error: Received 500 response] when trying to create a new court case using 'https://example.com/api/v1/court_case/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/'"
        )
        assert_requested(
          :post,
          "https://example.com/api/v1/court_case/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/",
          headers: { 'Content-Type': 'application/json', 'X-Api-Key': 'skeleton' },
          body: json_request_body,
          times: 1
        )
      end
    end
  end
end
