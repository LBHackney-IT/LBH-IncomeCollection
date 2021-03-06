require 'rails_helper'

describe Hackney::Income::AgreementsGateway do
  subject { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }

  describe '#create_agrement' do
    let(:request_params) do
      {
        tenancy_ref: Faker::Lorem.characters(number: 6),
        agreement_type: 'informal',
        frequency: %w[weekly monthly].sample,
        amount: Faker::Commerce.price(range: 10...100),
        start_date: Faker::Date.between(from: 2.days.ago, to: Date.today),
        created_by: Faker::Name.name,
        notes: Faker::ChuckNorris.fact,
        initial_payment_amount: Faker::Commerce.price(range: 10...100),
        initial_payment_date: Faker::Date.between(from: 2.days.ago, to: Date.today),
        court_case_id: nil
      }
    end

    let(:json_request_body) do
      {
        agreement_type: request_params.fetch(:agreement_type),
        frequency: request_params.fetch(:frequency),
        amount: request_params.fetch(:amount),
        start_date: request_params.fetch(:start_date),
        created_by: request_params.fetch(:created_by),
        notes: request_params.fetch(:notes),
        court_case_id: request_params.fetch(:court_case_id),
        initial_payment_amount: request_params.fetch(:initial_payment_amount),
        initial_payment_date: request_params.fetch(:initial_payment_date)
      }.to_json
    end

    context 'when sending a successful request to the API' do
      let(:new_agreement_id) { Faker::Number.number(digits: 3) }

      before do
        stub_request(:post, "https://example.com/api/v1/agreement/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/")
          .to_return(
            status: 200,
            body: {
              id: new_agreement_id,
              history: []
            }.to_json
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

      it 'should map the response into an agreement' do
        new_agreement = subject.create_agreement(**request_params)

        expect(new_agreement.id).to eq(new_agreement_id)
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

  describe '#view_agrements' do
    let(:tenancy_ref) { Faker::Lorem.characters(number: 6) }
    let(:agreements_response) do
      {
        agreements:
          [
            {
              id: Faker::Number.number(digits: 3),
              tenancyRef: tenancy_ref,
              agreementType: 'informal',
              startingBalance: Faker::Commerce.price(range: 10...1000),
              amount: Faker::Commerce.price(range: 10...100),
              startDate: Faker::Date.between(from: 2.days.ago, to: Date.today).to_s,
              frequency: %w[weekly monthly].sample,
              currentState: 'live',
              createdBy: Faker::Number.number(digits: 8),
              createdAt: Faker::Date.between(from: 6.days.ago, to: 3.days.ago).to_s,
              lastChecked: Faker::Date.between(from: 3.days.ago, to: 2.days.ago).to_s,
              initialPaymentAmount: Faker::Commerce.price(range: 50...300),
              initialPaymentDate: Faker::Date.between(from: 5.days.ago, to: 3.days.ago).to_s,
              history: [
                {
                  state: 'live',
                  date: Faker::Date.between(from: 2.days.ago, to: Date.today).to_s,
                  checkedBalance: Faker::Commerce.price(range: 10...100),
                  expectedBalance: Faker::Commerce.price(range: 10...100),
                  description: Faker::ChuckNorris.fact
                }
              ]
            },
            {
              id: Faker::Number.number(digits: 3),
              tenancyRef: tenancy_ref,
              agreementType: 'informal',
              startingBalance: Faker::Commerce.price(range: 10...1000),
              amount: Faker::Commerce.price(range: 10...100),
              startDate: Faker::Date.between(from: 2.days.ago, to: Date.today).to_s,
              frequency: %w[weekly monthly].sample,
              currentState: 'live',
              createdBy: Faker::Number.number(digits: 8),
              createdAt: Faker::Date.between(from: 6.days.ago, to: 3.days.ago).to_s,
              lastChecked: Faker::Date.between(from: 3.days.ago, to: 2.days.ago).to_s,
              initialPaymentAmount: nil,
              initialPaymentDate: nil,
              history: [
                {
                  state: 'live',
                  date: Faker::Date.between(from: 2.days.ago, to: Date.today).to_s,
                  checkedBalance: Faker::Commerce.price(range: 10...100),
                  expectedBalance: Faker::Commerce.price(range: 10...100),
                  description: Faker::ChuckNorris.fact
                }
              ]
            }
          ]
        }
    end

    context 'geting agreements for a tenancy' do
      before do
        stub_request(:get, "https://example.com/api/v1/agreements/#{ERB::Util.url_encode(tenancy_ref)}/")
          .to_return(
            body: agreements_response.to_json
          )
      end

      it 'should return the agreements for the tenancy' do
        agreements = subject.view_agreements(tenancy_ref: tenancy_ref)

        agreements.each_with_index do |agreement, i|
          expect(agreement.id).to eq(agreements_response[:agreements][i].fetch(:id))
          expect(agreement.tenancy_ref).to eq(agreements_response[:agreements][i].fetch(:tenancyRef))
          expect(agreement.agreement_type).to eq(agreements_response[:agreements][i].fetch(:agreementType))
          expect(agreement.starting_balance).to eq(agreements_response[:agreements][i].fetch(:startingBalance))
          expect(agreement.amount).to eq(agreements_response[:agreements][i].fetch(:amount))
          expect(agreement.start_date).to eq(agreements_response[:agreements][i].fetch(:startDate))
          expect(agreement.frequency).to eq(agreements_response[:agreements][i].fetch(:frequency))
          expect(agreement.current_state).to eq(agreements_response[:agreements][i].fetch(:currentState))
          expect(agreement.created_at).to eq(agreements_response[:agreements][i].fetch(:createdAt))
          expect(agreement.created_by).to eq(agreements_response[:agreements][i].fetch(:createdBy))
          expect(agreement.last_checked).to eq(agreements_response[:agreements][i].fetch(:lastChecked))
          expect(agreement.initial_payment_amount).to eq(agreements_response[:agreements][i].fetch(:initialPaymentAmount))
          expect(agreement.initial_payment_date).to eq(agreements_response[:agreements][i].fetch(:initialPaymentDate))
          expect(agreement.history.first.date).to eq(agreements_response[:agreements][i].fetch(:history).first.fetch(:date))
          expect(agreement.history.first.state).to eq(agreements_response[:agreements][i].fetch(:history).first.fetch(:state))
          expect(agreement.history.first.checked_balance).to eq(agreements_response[:agreements][i].fetch(:history).first.fetch(:checkedBalance))
          expect(agreement.history.first.expected_balance).to eq(agreements_response[:agreements][i].fetch(:history).first.fetch(:expectedBalance))
          expect(agreement.history.first.description).to eq(agreements_response[:agreements][i].fetch(:history).first.fetch(:description))
        end
      end
    end

    context 'when receiving a 500 error from the API' do
      before do
        stub_request(:get, "https://example.com/api/v1/agreements/#{ERB::Util.url_encode(tenancy_ref)}/")
          .to_return(
            status: 500
          )
      end

      it 'should raise an error' do
        expect do
          subject.view_agreements(tenancy_ref: tenancy_ref)
        end.to raise_error(
          Exceptions::IncomeApiError,
          "[Income API error: Received 500 response] when trying to get agreements using 'https://example.com/api/v1/agreements/#{ERB::Util.url_encode(tenancy_ref)}/'"
        )
      end
    end
  end

  describe '#cancel_agrement' do
    let(:agreement_id) { Faker::Lorem.characters(number: 6) }
    let(:cancellation_reason) { Faker::Lorem.characters(number: 40) }
    let(:cancelled_by) { Faker::Name.name.to_s }
    let(:json_request_body) do
      {
        cancelled_by: cancelled_by,
        cancellation_reason: cancellation_reason
      }.to_json
    end

    before do
      stub_request(:post, "https://example.com/api/v1/agreements/#{ERB::Util.url_encode(agreement_id)}/cancel")
        .to_return(
          status: 200
        )
    end

    it 'should send the required params' do
      subject.cancel_agreement(agreement_id: agreement_id, cancelled_by: cancelled_by, cancellation_reason: cancellation_reason)

      assert_requested(
        :post,
        "https://example.com/api/v1/agreements/#{ERB::Util.url_encode(agreement_id)}/cancel",
        headers: { 'Content-Type': 'application/json', 'X-Api-Key': 'skeleton' },
        body: json_request_body,
        times: 1
      )
    end

    context 'when receiving an error from the API' do
      let(:agreement_id) { Faker::Lorem.characters(number: 6) }
      let(:error_code) { [404, 500].sample }

      before do
        stub_request(:post, "https://example.com/api/v1/agreements/#{ERB::Util.url_encode(agreement_id)}/cancel")
          .to_return(
            status: error_code
          )
      end

      it 'should raise and error' do
        expect do
          subject.cancel_agreement(agreement_id: agreement_id, cancellation_reason: cancellation_reason, cancelled_by: cancelled_by)
        end.to raise_error(
          Exceptions::IncomeApiError,
          "[Income API error: Received #{error_code} response] when trying to cancel the agreement using 'https://example.com/api/v1/agreements/#{ERB::Util.url_encode(agreement_id)}/cancel'"
        )
        assert_requested(
          :post,
          "https://example.com/api/v1/agreements/#{ERB::Util.url_encode(agreement_id)}/cancel",
          headers: { 'Content-Type': 'application/json', 'X-Api-Key': 'skeleton' },
          times: 1
        )
      end
    end
  end
end
