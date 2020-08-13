require 'rails_helper'

describe Hackney::Income::CourtCasesGateway do
  subject { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }
  let(:tenancy_ref) { "#{Faker::Lorem.characters(number: 6)}/#{Faker::Lorem.characters(number: 2)}" }

  describe '#create_court_case' do
    let(:request_params) do
      {
        tenancy_ref: tenancy_ref,
        court_date: Faker::Date.between(from: 5.days.ago, to: Date.today),
        court_outcome: nil,
        balance_on_court_outcome_date: nil,
        strike_out_date: nil,
        terms: nil,
        disrepair_counter_claim: nil
      }
    end

    let(:json_request_body) do
      {
        court_date: request_params.fetch(:court_date),
        court_outcome: request_params.fetch(:court_outcome),
        balance_on_court_outcome_date: request_params.fetch(:balance_on_court_outcome_date),
        strike_out_date: request_params.fetch(:strike_out_date),
        terms: request_params.fetch(:terms),
        disrepair_counter_claim: request_params.fetch(:disrepair_counter_claim)
      }.to_json
    end

    context 'when sending a successful request to the API' do
      before do
        stub_request(:post, "https://example.com/api/v1/court_case/#{ERB::Util.url_encode(tenancy_ref)}/")
          .to_return(
            status: 200
          )
      end

      it 'should send the required params' do
        subject.create_court_case(create_court_case_params: request_params)

        assert_requested(
          :post,
          "https://example.com/api/v1/court_case/#{ERB::Util.url_encode(tenancy_ref)}/",
          headers: { 'Content-Type': 'application/json', 'X-Api-Key': 'skeleton' },
          body: json_request_body,
          times: 1
        )
      end
    end

    context 'when receiving a 500 error from the API' do
      before do
        stub_request(:post, "https://example.com/api/v1/court_case/#{ERB::Util.url_encode(tenancy_ref)}/")
          .to_return(
            status: 500
          )
      end

      it 'should raise and error' do
        expect do
          subject.create_court_case(create_court_case_params: request_params)
        end.to raise_error(
          Exceptions::IncomeApiError,
          "[Income API error: Received 500 response] when trying to create a new court case using 'https://example.com/api/v1/court_case/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/'"
        )
        assert_requested(
          :post,
          "https://example.com/api/v1/court_case/#{ERB::Util.url_encode(tenancy_ref)}/",
          headers: { 'Content-Type': 'application/json', 'X-Api-Key': 'skeleton' },
          body: json_request_body,
          times: 1
        )
      end
    end
  end

  describe '#view_court_cases' do
    let(:response_body) do
      { courtCases:
        [{
          id: Faker::Number.number(digits: 3),
          tenancyRef: tenancy_ref,
          courtDate: Faker::Date.between(from: 5.days.ago, to: Date.today),
          courtOutcome: nil,
          balanceOnCourtOutcomeDate: nil,
          strikeOutDate: nil,
          terms: nil,
          disrepairCounterClaim: nil
        }] }.to_json
    end

    context 'when sending a successful request to the API' do
      before do
        stub_request(:get, "https://example.com/api/v1/court_cases/#{ERB::Util.url_encode(tenancy_ref)}/")
          .to_return(
            status: 200,
            body: response_body
          )
      end

      it 'should send the required params' do
        court_cases = subject.view_court_cases(tenancy_ref: tenancy_ref)

        expect(court_cases.count).to be(1)
      end
    end

    context 'when receiving a 500 error from the API' do
      before do
        stub_request(:get, "https://example.com/api/v1/court_cases/#{ERB::Util.url_encode(tenancy_ref)}/")
          .to_return(
            status: 500
          )
      end

      it 'should raise and error' do
        expect do
          subject.view_court_cases(tenancy_ref: tenancy_ref)
        end.to raise_error(
          Exceptions::IncomeApiError,
          "[Income API error: Received 500 response] when trying to get court cases using 'https://example.com/api/v1/court_cases/#{ERB::Util.url_encode(tenancy_ref)}/'"
        )
        assert_requested(
          :get,
          "https://example.com/api/v1/court_cases/#{ERB::Util.url_encode(tenancy_ref)}/",
          headers: { 'Content-Type': 'application/json', 'X-Api-Key': 'skeleton' },
          times: 1
        )
      end
    end
  end

  describe '#update_court_case' do
    let(:id) { Faker::Number.number(digits: 3) }
    let(:court_date) { Faker::Date.between(from: 2.days.ago, to: Date.today) }
    
    let(:request_params) do
      {
        id: id,
        court_date: court_date,
        court_outcome: nil,
        balance_on_court_outcome_date: nil,
        strike_out_date: nil,
        terms: nil,
        disrepair_counter_claim: nil
      }
    end

    let(:json_request_body) do
      {
        court_date: request_params.fetch(:court_date),
        court_outcome: request_params.fetch(:court_outcome),
        balance_on_court_outcome_date: request_params.fetch(:balance_on_court_outcome_date),
        strike_out_date: request_params.fetch(:strike_out_date),
        terms: request_params.fetch(:terms),
        disrepair_counter_claim: request_params.fetch(:disrepair_counter_claim)
      }.to_json
    end

    context 'when sending a successful request to the API' do
      before do
        stub_request(:patch, "https://example.com/api/v1/court_case/#{ERB::Util.url_encode(id)}/update")
          .to_return(
            status: 200
          )
      end

      it 'should send the required params' do
        subject.update_court_case(court_case_params: request_params)

        assert_requested(
          :patch,
          "https://example.com/api/v1/court_case/#{ERB::Util.url_encode(id)}/update",
          headers: { 'Content-Type': 'application/json', 'X-Api-Key': 'skeleton' },
          body: json_request_body,
          times: 1
        )
      end
    end

    context 'when receiving a 500 error from the API' do
      before do
        stub_request(:patch, "https://example.com/api/v1/court_case/#{ERB::Util.url_encode(id)}/update")
          .to_return(
            status: 500
          )
      end

      it 'should raise and error' do
        expect do
          subject.update_court_case(court_case_params: request_params)
        end.to raise_error(
          Exceptions::IncomeApiError,
          "[Income API error: Received 500 response] when trying to update the court case using 'https://example.com/api/v1/court_case/#{ERB::Util.url_encode(id)}/update'"
        )
        assert_requested(
          :patch,
          "https://example.com/api/v1/court_case/#{ERB::Util.url_encode(id)}/update",
          headers: { 'Content-Type': 'application/json', 'X-Api-Key': 'skeleton' },
          body: json_request_body,
          times: 1
        )
      end
    end
  end
end
