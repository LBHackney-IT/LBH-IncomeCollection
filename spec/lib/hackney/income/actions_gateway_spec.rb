require 'rails_helper'

describe Hackney::Income::ActionsGateway do
  let(:actions_gateway) { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }

  context 'when pulling actions' do
    let(:page_number) { Faker::Number.number(digits: 2).to_i }
    let(:number_per_page) { Faker::Number.number(digits: 2).to_i }
    let(:paused) { false }
    let(:full_patch) { false }
    let(:patch_code) { Faker::Lorem.characters(number: 3) }
    let(:filter_params) do
      Hackney::Income::FilterParams::ListCasesParams.new(
        page: page_number,
        count_per_page: number_per_page,
        paused: paused,
        full_patch: full_patch,
        patch_code: patch_code
      )
    end

    subject do
      actions_gateway.get_actions(
        filter_params: filter_params
      )
    end

    context 'when the api is returning errors' do
      before do
        stub_request(:get, 'https://example.com/api/v1/actions')
            .with(query: hash_including({}))
            .to_return(status: [500, 'oh no!'])
      end

      it 'should raise a IncomeApiError' do
        expect { subject }.to raise_error(Exceptions::IncomeApiError, "[Income API error: Received 500 response] when trying to get_actions for Params '#{filter_params.to_params.inspect}'")
      end
    end

    context 'when the api is running' do
      before do
        stub_request(:get, 'https://example.com/api/v1/actions')
            .with(query: hash_including({}))
            .to_return(body: stub_response.to_json)
      end

      let(:stub_response) { { actions: stub_actions, number_of_pages: number_of_pages } }
      let(:number_of_pages) { Faker::Number.number(digits: 3).to_i }
      let(:stub_actions) do
        [
            {
                tenancy_ref: "#{Faker::Number.number(digits: 6)}/#{Faker::Number.number(digits: 2)}",
                balance: Faker::Number.decimal(l_digits: 3, r_digits: 3),
                payment_ref: Faker::Number.number(digits: 10).to_s,
                patch_code: Faker::Alphanumeric.alpha(number: 3).upcase,
                action_type: Faker::Music::RockBand.name,
                service_area_type: :leasehold,
                metadata: {
                    property_address: "#{Faker::Address.street_address}, London, #{Faker::Address.postcode}",
                    lessee: Faker::Name.name,
                    tenure_type: Faker::Music::RockBand.name,
                    direct_debit_status: ['Live', 'First Payment', 'Cancelled', 'Last Payment'].sample,
                    latest_letter: Faker::Alphanumeric.alpha(number: 3).upcase,
                    latest_letter_date: Faker::Date.between(from: 20.days.ago, to: Date.today).to_s
                }
            }
        ]
      end

      it 'should look up actions with filter params passed in' do
        subject
        request = a_request(:get, 'https://example.com/api/v1/actions').with(
          headers: { 'X-Api-Key' => 'skeleton' },
          query: {
              'page_number' => page_number,
              'number_per_page' => number_per_page,
              'is_paused' => paused,
              'full_patch' => full_patch,
              'upcoming_court_dates' => false,
              'upcoming_evictions' => false,
              'patch' => patch_code
          }
        )

        expect(request).to have_been_made
      end

      it 'should include all actions' do
        expect(subject[:actions].count).to eq(stub_actions.count)
      end

      it 'should include the number of pages' do
        expect(subject[:number_of_pages]).to eq(number_of_pages)
      end
    end
  end
end
