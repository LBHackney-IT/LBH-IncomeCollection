require 'rails_helper'

describe Hackney::Income::LessDangerousTenancyGateway do
  let(:tenancy_gateway) { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }

  context 'when pulling prioritised tenancies' do
    subject { tenancy_gateway.get_tenancies(tenancy_refs) }

    context 'when given no tenancy refs' do
      let(:tenancy_refs) { [] }

      it 'should not call the my-cases endpoint' do
        subject
        expect(a_request(:get, 'https://example.com/api/my-cases')).not_to have_been_made
      end
    end

    context 'when given tenancy refs' do
      before do
        stub_request(:get, 'https://example.com/api/my-cases')
          .with(query: hash_including({}))
          .to_return(body: stub_response.to_json)
      end

      let(:stub_response) do
        Array.new(Faker::Number.number(2).to_i).map { example_tenancy_list_response_item }
      end

      let(:tenancy_refs) do
        stub_response.map { |t| t.fetch(:ref) }
      end

      it 'should look up all tenancies passed in' do
        subject

        request = a_request(:get, 'https://example.com/api/my-cases').with(
          headers: { 'X-Api-Key' => 'skeleton' },
          query: { 'tenancy_refs' => tenancy_refs }
        )

        expect(request).to have_been_made
      end

      it 'should include all tenancies' do
        expect(subject.count).to eq(stub_response.count)
        expect(subject.map(&:ref)).to eq(stub_response.map { |t| t[:ref] })
      end

      context 'for each tenancy' do
        let(:stub_response) do
          [example_tenancy_list_response_item(current_balance: '¤5,675.89')]
        end

        let(:expected_tenancy) { stub_response.first }

        it 'should include a score' do
          expect(subject.first.score).to eq(expected_tenancy[:priority_score])
        end

        it 'should include a band' do
          expect(subject.first.band).to eq(expected_tenancy[:priority_band])
        end

        it 'should include the contributions made to the score' do
          expect(subject.first.balance_contribution).to eq(expected_tenancy[:balance_contribution])
          expect(subject.first.days_in_arrears_contribution).to eq(expected_tenancy[:days_in_arrears_contribution])
          expect(subject.first.days_since_last_payment_contribution).to eq(expected_tenancy[:days_since_last_payment_contribution])
          expect(subject.first.payment_amount_delta_contribution).to eq(expected_tenancy[:payment_amount_delta_contribution])
          expect(subject.first.payment_date_delta_contribution).to eq(expected_tenancy[:payment_date_delta_contribution])
          expect(subject.first.number_of_broken_agreements_contribution).to eq(expected_tenancy[:number_of_broken_agreements_contribution])
          expect(subject.first.active_agreement_contribution).to eq(expected_tenancy[:active_agreement_contribution])
          expect(subject.first.broken_court_order_contribution).to eq(expected_tenancy[:broken_court_order_contribution])
          expect(subject.first.nosp_served_contribution).to eq(expected_tenancy[:nosp_served_contribution])
          expect(subject.first.active_nosp_contribution).to eq(expected_tenancy[:active_nosp_contribution])
        end

        it 'should include some useful info for displaying the priority contributions in a readable way' do
          expect(subject.first.days_in_arrears).to eq(expected_tenancy[:days_in_arrears])
          expect(subject.first.days_since_last_payment).to eq(expected_tenancy[:days_since_last_payment])
          expect(subject.first.payment_amount_delta).to eq(expected_tenancy[:payment_amount_delta])
          expect(subject.first.payment_date_delta).to eq(expected_tenancy[:payment_date_delta])
          expect(subject.first.number_of_broken_agreements).to eq(expected_tenancy[:number_of_broken_agreements])
          expect(subject.first.broken_court_order).to eq(expected_tenancy[:broken_court_order])
          expect(subject.first.nosp_served).to eq(expected_tenancy[:nosp_served])
          expect(subject.first.active_nosp).to eq(expected_tenancy[:active_nosp])
        end

        it 'should include balances, converting those given as currencies' do
          expect(subject.first.current_balance).to eq(5_675.89)
        end

        it 'should include current agreement status' do
          expect(subject.first.current_arrears_agreement_status).to eq(expected_tenancy[:current_arrears_agreement_status])
        end

        it 'should include latest action code' do
          expect(subject.first.latest_action_code).to eq(expected_tenancy[:latest_action][:code])
        end

        it 'should include latest action date' do
          expect(subject.first.latest_action_date).to eq(expected_tenancy[:latest_action][:date].strftime('%Y-%m-%d'))
        end

        it 'should include basic contact details - name' do
          expect(subject.first.primary_contact_name).to eq(expected_tenancy[:primary_contact][:name])
        end

        it 'should include basic contact details - short address' do
          expect(subject.first.primary_contact_short_address).to eq(expected_tenancy[:primary_contact][:short_address])
        end

        it 'should include basic contact details - postcode' do
          expect(subject.first.primary_contact_postcode).to eq(expected_tenancy[:primary_contact][:postcode])
        end
      end

      context 'in a staging environment' do
        let(:stub_response) do
          [example_tenancy_list_response_item]
        end

        before do
          allow(Rails.env).to receive(:staging?).and_return(true)
        end

        let(:seeded_prioritised_tenancy) do
          {
            primary_contact_name: 'Dr. Katheryn Jakubowski',
            primary_contact_short_address: '4524 Cormier Vista',
            primary_contact_postcode: '26778'
          }
        end

        it 'should obfuscate the name, address and postcode for each prioritised list item' do
          expect(subject.first.primary_contact_short_address).to eq(seeded_prioritised_tenancy[:primary_contact_short_address])
          expect(subject.first.primary_contact_name).to eq(seeded_prioritised_tenancy[:primary_contact_name])
          expect(subject.first.primary_contact_postcode).to eq(seeded_prioritised_tenancy[:primary_contact_postcode])
        end
      end
    end
  end

  context 'when receiving details of a single tenancy' do
    let(:triangulated_stub_tenancy_response) { example_single_tenancy_response }
    let(:stub_response) do
      example_single_tenancy_response(
        tenancy_details: {
          rent: '¤1,234.56',
          service: '¤2,234.56',
          other_charge: '¤3,234.56',
          current_balance: '¤4,234.56'
        }
      )
    end

    before do
      stub_request(:get, 'https://example.com/api/tenancies/FAKE%2F01')
        .to_return(body: stub_response.to_json)

      stub_request(:get, 'https://example.com/api/tenancies/FAKE%2F02')
        .to_return(body: triangulated_stub_tenancy_response.to_json)
    end

    subject { tenancy_gateway.get_tenancy(tenancy_ref: 'FAKE/01') }
    let(:expected_details) { stub_response.fetch(:tenancy_details) }

    it 'should return a single tenancy matching the reference given with converted currencies' do
      expect(subject).to be_instance_of(Hackney::Income::Domain::Tenancy)
      expect(subject.ref).to eq(expected_details.fetch(:ref))
      expect(subject.tenure).to eq(expected_details.fetch(:tenure))
      expect(subject.rent).to eq(1234.56)
      expect(subject.service).to eq(2234.56)
      expect(subject.other_charge).to eq(3234.56)
      expect(subject.current_balance).to eq(4234.56)
    end

    it 'should return a single tenancy matching the reference given' do
      tenancy = tenancy_gateway.get_tenancy(tenancy_ref: 'FAKE/02')
      expected_details = triangulated_stub_tenancy_response.fetch(:tenancy_details)

      expect(tenancy).to be_instance_of(Hackney::Income::Domain::Tenancy)
      expect(tenancy.ref).to eq(expected_details.fetch(:ref))
      expect(tenancy.tenure).to eq(expected_details.fetch(:tenure))
      expect(tenancy.rent).to eq(expected_details.fetch(:rent).to_f)
      expect(tenancy.service).to eq(expected_details.fetch(:service).to_f)
      expect(tenancy.other_charge).to eq(expected_details.fetch(:other_charge).to_f)
      expect(tenancy.current_balance).to eq(expected_details.fetch(:current_balance).to_f)
    end

    it 'should include the contact details and current state of the account' do
      expect(subject.current_arrears_agreement_status).to eq(expected_details.fetch(:current_arrears_agreement_status))
      expect(subject.primary_contact_name).to eq(expected_details.fetch(:primary_contact_name))
      expect(subject.primary_contact_long_address).to eq(expected_details.fetch(:primary_contact_long_address))
      expect(subject.primary_contact_postcode).to eq(expected_details.fetch(:primary_contact_postcode))
    end

    let(:expected_actions) { stub_response.fetch(:latest_action_diary_events) }
    let(:expected_agreements) { stub_response.fetch(:latest_arrears_agreements) }

    it 'should include the latest 5 action diary events' do
      expect(subject.arrears_actions.length).to eq(5)

      subject.arrears_actions.each_with_index do |action, i|
        assert_action_diary_event(expected_actions[i], action)
      end
    end

    it 'should include the latest 5 arrears actions' do
      expect(subject.agreements.length).to eq(5)

      subject.agreements.each_with_index do |agreement, i|
        assert_agreement(expected_agreements[i], agreement)
      end
    end

    context 'in a staging environment' do
      let(:stub_response) do
        {
          tenancy_details:
          {
            ref: '12345',
            tenure: Faker::Lorem.characters(3),
            rent: "¤#{Faker::Number.decimal(2)}",
            service: "¤#{Faker::Number.decimal(2)}",
            other_charge: "¤#{Faker::Number.decimal(2)}",
            current_arrears_agreement_status: Faker::Lorem.characters(3),
            current_balance: "¤#{Faker::Number.decimal(2)}",
            primary_contact_name: Faker::Name.first_name,
            primary_contact_long_address: Faker::Address.street_address,
            primary_contact_postcode: Faker::Lorem.word
          },
          latest_action_diary_events: Array.new(5) { action_diary_event },
          latest_arrears_agreements: Array.new(5) { arrears_agreement }
        }
      end

      before do
        stub_request(:get, 'https://example.com/api/tenancies/FAKE%2F01')
          .to_return(body: stub_response.to_json)

        allow(Rails.env).to receive(:staging?).and_return(true)
      end

      let(:single_tenancy) { tenancy_gateway.get_tenancy(tenancy_ref: 'FAKE/01') }
      let(:expected_tenancy) do
        {
          primary_contact_name: 'Ms. Trent Friesen',
          primary_contact_long_address: '8602 Maggio Hollow',
          primary_contact_postcode: '22677'
        }
      end

      it 'should obfuscate the name, address and postcode for each single tenancy item' do
        expect(single_tenancy.primary_contact_long_address).to eq(expected_tenancy[:primary_contact_long_address])
        expect(single_tenancy.primary_contact_name).to eq(expected_tenancy[:primary_contact_name])
        expect(single_tenancy.primary_contact_postcode).to eq(expected_tenancy[:primary_contact_postcode])
      end
    end
  end
end

def action_diary_event
  {
    balance: Faker::Number.decimal(2),
    code: Faker::Lorem.characters(3),
    type: Faker::Lorem.characters(3),
    date: Faker::Date.forward(100),
    comment: Faker::Lovecraft.sentences(2),
    universal_housing_username: Faker::Name.first_name
  }
end

def arrears_agreement
  {
    amount: Faker::Number.decimal(2),
    breached: Faker::Lorem.characters(3),
    clear_by: Faker::Date.forward(100),
    frequency: Faker::Lorem.characters(5),
    start_balance: Faker::Number.decimal(2),
    start_date: Faker::Date.forward(10),
    status: Faker::Lorem.characters(3)
  }
end

def assert_action_diary_event(expected, actual)
  expect(expected.fetch(:balance).to_f).to eq(actual.balance)
  expect(expected.fetch(:code)).to eq(actual.code)
  expect(expected.fetch(:type)).to eq(actual.type)
  expect(expected.fetch(:date).strftime('%Y-%m-%d')).to eq(actual.date)
  expect(expected.fetch(:comment)).to eq(actual.comment)
  expect(expected.fetch(:universal_housing_username)).to eq(actual.universal_housing_username)
end

def assert_agreement(expected, actual)
  expect(expected.fetch(:amount).to_f).to eq(actual.amount)
  expect(expected.fetch(:breached)).to eq(actual.breached)
  expect(expected.fetch(:clear_by).strftime('%Y-%m-%d')).to eq(actual.clear_by)
  expect(expected.fetch(:frequency)).to eq(actual.frequency)
  expect(expected.fetch(:start_balance)).to eq(actual.start_balance)
  expect(expected.fetch(:start_date).strftime('%Y-%m-%d')).to eq(actual.start_date)
  expect(expected.fetch(:status)).to eq(actual.status)
end

def example_tenancy_list_response_item(options = {})
  options.reverse_merge(
    ref: Faker::Lorem.characters(8),
    current_balance: Faker::Number.decimal(2),
    current_arrears_agreement_status: Faker::Lorem.characters(3),
    latest_action:
    {
      code: Faker::Lorem.characters(10),
      date: Faker::Date.forward(100)
    },
    primary_contact:
    {
      name: Faker::Name.first_name,
      short_address: Faker::Address.street_address,
      postcode: Faker::Lorem.word
    },
    priority_score: Faker::Number.number(3),
    priority_band: Faker::Lorem.characters(5),

    balance_contribution: Faker::Number.number(2),
    days_in_arrears_contribution: Faker::Number.number(2),
    days_since_last_payment_contribution: Faker::Number.number(2),
    payment_amount_delta_contribution: Faker::Number.number(2),
    payment_date_delta_contribution: Faker::Number.number(2),
    number_of_broken_agreements_contribution: Faker::Number.number(2),
    active_agreement_contribution: Faker::Number.number(2),
    broken_court_order_contribution: Faker::Number.number(2),
    nosp_served_contribution: Faker::Number.number(2),
    active_nosp_contribution: Faker::Number.number(2),

    days_in_arrears: Faker::Number.number(2),
    days_since_last_payment: Faker::Number.number(2),
    payment_amount_delta: Faker::Number.number(2),
    payment_date_delta: Faker::Number.number(2),
    number_of_broken_agreements: Faker::Number.number(2),
    broken_court_order: Faker::Number.between(0, 1),
    nosp_served: Faker::Number.between(0, 1),
    active_nosp: Faker::Number.between(0, 1)
  )
end

def example_single_tenancy_response(options = {})
  {
    tenancy_details: {
      ref: Faker::Lorem.characters(8),
      tenure: Faker::Lorem.characters(3),
      rent: Faker::Number.decimal(5),
      service: Faker::Number.decimal(4),
      other_charge: Faker::Number.decimal(4),
      current_arrears_agreement_status: Faker::Lorem.characters(3),
      current_balance: Faker::Number.decimal(2),
      primary_contact_name: Faker::Name.first_name,
      primary_contact_long_address: Faker::Address.street_address,
      primary_contact_postcode: Faker::Lorem.word
    },
    latest_action_diary_events: Array.new(5) { action_diary_event },
    latest_arrears_agreements: Array.new(5) { arrears_agreement }
  }.deep_merge(options)
end
