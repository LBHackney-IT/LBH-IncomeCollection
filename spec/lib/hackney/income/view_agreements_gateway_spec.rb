require 'rails_helper'

describe Hackney::Income::ViewAgreementsGateway do
  subject { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }

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
            history: [
              {
                state: 'live',
                date: Faker::Date.between(from: 2.days.ago, to: Date.today).to_s
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
            history: [
              {
                state: 'live',
                date: Faker::Date.between(from: 2.days.ago, to: Date.today).to_s
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
        expect(agreement.history.first.date).to eq(agreements_response[:agreements][i].fetch(:history).first.fetch(:date))
        expect(agreement.history.first.state).to eq(agreements_response[:agreements][i].fetch(:history).first.fetch(:state))
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
