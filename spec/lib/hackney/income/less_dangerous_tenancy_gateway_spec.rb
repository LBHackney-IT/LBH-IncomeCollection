require 'rails_helper'

describe Hackney::Income::LessDangerousTenancyGateway do
  let(:tenancy_gateway) { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }

  context 'when pulling prioritised tenancies' do
    let(:user_id) { Faker::Number.number(2).to_i }
    let(:page_number) { Faker::Number.number(2).to_i }
    let(:number_per_page) { Faker::Number.number(2).to_i }

    subject do
      tenancy_gateway.get_tenancies(
        user_id: user_id,
        page_number: page_number,
        number_per_page: number_per_page
      )
    end

    before do
      stub_request(:get, 'https://example.com/api/my-cases')
        .with(query: hash_including({}))
        .to_return(body: stub_response.to_json)
    end

    let(:stub_response) { { cases: stub_tenancies, number_of_pages: number_of_pages } }
    let(:number_of_pages) { Faker::Number.number(3).to_i }
    let(:stub_tenancies) do
      Array.new(Faker::Number.number(2).to_i).map { example_tenancy_list_response_item }
    end

    it 'should look up tenancies for the user id and page params passed in' do
      subject

      request = a_request(:get, 'https://example.com/api/my-cases').with(
        headers: { 'X-Api-Key' => 'skeleton' },
        query: {
          'user_id' => user_id,
          'page_number' => page_number,
          'number_per_page' => number_per_page
        }
      )

      expect(request).to have_been_made
    end

    it 'should include all tenancies' do
      expect(subject.tenancies.count).to eq(stub_tenancies.count)
      expect(subject.tenancies.map(&:ref)).to eq(stub_tenancies.map { |t| t[:ref] })
    end

    it 'should include the number of pages' do
      expect(subject.number_of_pages).to eq(number_of_pages)
    end

    context 'for each tenancy' do
      let(:stub_tenancies) do
        [example_tenancy_list_response_item(current_balance: '¤5,675.89')]
      end

      let(:expected_tenancy) { stub_tenancies.first }

      it 'should include a score' do
        expect(subject.tenancies.first.score).to eq(expected_tenancy[:priority_score])
      end

      it 'should include a band' do
        expect(subject.tenancies.first.band).to eq(expected_tenancy[:priority_band])
      end

      it 'should include the contributions made to the score' do
        expect(subject.tenancies.first.balance_contribution).to eq(expected_tenancy[:balance_contribution])
        expect(subject.tenancies.first.days_in_arrears_contribution).to eq(expected_tenancy[:days_in_arrears_contribution])
        expect(subject.tenancies.first.days_since_last_payment_contribution).to eq(expected_tenancy[:days_since_last_payment_contribution])
        expect(subject.tenancies.first.payment_amount_delta_contribution).to eq(expected_tenancy[:payment_amount_delta_contribution])
        expect(subject.tenancies.first.payment_date_delta_contribution).to eq(expected_tenancy[:payment_date_delta_contribution])
        expect(subject.tenancies.first.number_of_broken_agreements_contribution).to eq(expected_tenancy[:number_of_broken_agreements_contribution])
        expect(subject.tenancies.first.active_agreement_contribution).to eq(expected_tenancy[:active_agreement_contribution])
        expect(subject.tenancies.first.broken_court_order_contribution).to eq(expected_tenancy[:broken_court_order_contribution])
        expect(subject.tenancies.first.nosp_served_contribution).to eq(expected_tenancy[:nosp_served_contribution])
        expect(subject.tenancies.first.active_nosp_contribution).to eq(expected_tenancy[:active_nosp_contribution])
      end

      it 'should include some useful info for displaying the priority contributions in a readable way' do
        expect(subject.tenancies.first.days_in_arrears).to eq(expected_tenancy[:days_in_arrears])
        expect(subject.tenancies.first.days_since_last_payment).to eq(expected_tenancy[:days_since_last_payment])
        expect(subject.tenancies.first.payment_amount_delta).to eq(expected_tenancy[:payment_amount_delta])
        expect(subject.tenancies.first.payment_date_delta).to eq(expected_tenancy[:payment_date_delta])
        expect(subject.tenancies.first.number_of_broken_agreements).to eq(expected_tenancy[:number_of_broken_agreements])
        expect(subject.tenancies.first.broken_court_order).to eq(expected_tenancy[:broken_court_order])
        expect(subject.tenancies.first.nosp_served).to eq(expected_tenancy[:nosp_served])
        expect(subject.tenancies.first.active_nosp).to eq(expected_tenancy[:active_nosp])
      end

      it 'should include balances, converting those given as currencies' do
        expect(subject.tenancies.first.current_balance).to eq(5_675.89)
      end

      it 'should include current agreement status' do
        expect(subject.tenancies.first.current_arrears_agreement_status).to eq(expected_tenancy[:current_arrears_agreement_status])
      end

      it 'should include latest action code' do
        expect(subject.tenancies.first.latest_action_code).to eq(expected_tenancy[:latest_action][:code])
      end

      it 'should include latest action date' do
        expect(subject.tenancies.first.latest_action_date).to eq(expected_tenancy[:latest_action][:date].strftime('%Y-%m-%d'))
      end

      it 'should include basic contact details - name' do
        expect(subject.tenancies.first.primary_contact_name).to eq(expected_tenancy[:primary_contact][:name])
      end

      it 'should include basic contact details - short address' do
        expect(subject.tenancies.first.primary_contact_short_address).to eq(expected_tenancy[:primary_contact][:short_address])
      end

      it 'should include basic contact details - postcode' do
        expect(subject.tenancies.first.primary_contact_postcode).to eq(expected_tenancy[:primary_contact][:postcode])
      end
    end

    context 'in a staging environment' do
      let(:stub_tenancies) do
        [example_tenancy_list_response_item(ref: '000015/03')]
      end

      before do
        allow(Rails.env).to receive(:staging?).and_return(true)
      end

      let(:seeded_prioritised_tenancy) do
        {
          primary_contact_name: 'Mr. Reanna Mann',
          primary_contact_short_address: '796 Jacobs Burg',
          primary_contact_postcode: '23109-5863'
        }
      end

      it 'should obfuscate the name, address and postcode for each prioritised list item' do
        expect(subject.tenancies.first.primary_contact_short_address).to eq(seeded_prioritised_tenancy[:primary_contact_short_address])
        expect(subject.tenancies.first.primary_contact_name).to eq(seeded_prioritised_tenancy[:primary_contact_name])
        expect(subject.tenancies.first.primary_contact_postcode).to eq(seeded_prioritised_tenancy[:primary_contact_postcode])
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
          primary_contact_name: 'Ms. Mittie Torphy',
          primary_contact_long_address: '6216 O\'Reilly Point',
          primary_contact_postcode: '86029-1267'
        }
      end

      it 'should obfuscate the name, address and postcode for each single tenancy item' do
        expect(single_tenancy.primary_contact_long_address).to eq(expected_tenancy[:primary_contact_long_address])
        expect(single_tenancy.primary_contact_name).to eq(expected_tenancy[:primary_contact_name])
        expect(single_tenancy.primary_contact_postcode).to eq(expected_tenancy[:primary_contact_postcode])
      end
    end
  end

  context 'getting contact details for a tenancy ref' do
    let(:stub_single_response) { generate_contacts_response([generate_contact]) }
    let(:stub_joint_response) { generate_contacts_response(2.times.to_a.map { generate_contact }) }
    let(:stub_empty_response_1) { generate_contacts_response([]) }
    let(:stub_empty_response_2) { generate_contacts_response(nil) }

    before do
      stub_request(:get, 'https://example.com/api/tenancies/FAKE%2F01/contacts')
        .to_return(body: stub_single_response.to_json)
      stub_request(:get, 'https://example.com/api/tenancies/FAKE%2F02/contacts')
        .to_return(body: stub_joint_response.to_json)
      stub_request(:get, 'https://example.com/api/tenancies/FAKE%2F03/contacts')
        .to_return(body: stub_empty_response_1.to_json)
      stub_request(:get, 'https://example.com/api/tenancies/FAKE%2F04/contacts')
        .to_return(body: stub_empty_response_2.to_json)
    end

    context 'contact data is missing or fragmented' do
      it 'should return nothing if no contact was available' do
        contacts = tenancy_gateway.get_contacts_for(tenancy_ref: 'FAKE/03')
        expect(contacts).to eq([])
      end

      it 'should return nothing if nil was received' do
        contacts = tenancy_gateway.get_contacts_for(tenancy_ref: 'FAKE/04')
        expect(contacts).to eq([])
      end
    end

    context 'a single tenant' do
      it 'should have at least one contact' do
        contacts = tenancy_gateway.get_contacts_for(tenancy_ref: 'FAKE/01')
        expected_contact = stub_single_response[:data][:contacts].first

        expect(contacts.size).to eq(1)

        expect(contacts[0]).to be_instance_of(Hackney::Income::Domain::Contact)

        expect(contacts[0].contact_id).to eq(expected_contact.fetch(:contact_id))
        expect(contacts[0].email_address).to eq(expected_contact.fetch(:email_address))
        expect(contacts[0].uprn).to eq(expected_contact.fetch(:uprn))
        expect(contacts[0].address_line_1).to eq(expected_contact.fetch(:address_line1))
        expect(contacts[0].address_line_2).to eq(expected_contact.fetch(:address_line2))
        expect(contacts[0].address_line_3).to eq(expected_contact.fetch(:address_line3))
        expect(contacts[0].first_name).to eq(expected_contact.fetch(:first_name))
        expect(contacts[0].last_name).to eq(expected_contact.fetch(:last_name))
        expect(contacts[0].full_name).to eq(expected_contact.fetch(:full_name))
        expect(contacts[0].larn).to eq(expected_contact.fetch(:larn))
        expect(contacts[0].telephone_1).to eq(expected_contact.fetch(:telephone1))
        expect(contacts[0].telephone_2).to eq(expected_contact.fetch(:telephone2))
        expect(contacts[0].telephone_3).to eq(expected_contact.fetch(:telephone3))
        expect(contacts[0].cautionary_alert).to eq(expected_contact.fetch(:cautionary_alert))
        expect(contacts[0].property_cautionary_alert).to eq(expected_contact.fetch(:property_cautionary_alert))
        expect(contacts[0].house_ref).to eq(expected_contact.fetch(:house_ref))
        expect(contacts[0].title).to eq(expected_contact.fetch(:title))
        expect(contacts[0].full_address_display).to eq(expected_contact.fetch(:full_address_display))
        expect(contacts[0].full_address_search).to eq(expected_contact.fetch(:full_address_search))
        expect(contacts[0].post_code).to eq(expected_contact.fetch(:post_code))
        expect(contacts[0].date_of_birth).to eq(expected_contact.fetch(:date_of_birth).strftime('%Y-%m-%d'))
        expect(contacts[0].hackney_homes_id).to eq(expected_contact.fetch(:hackney_homes_id))
      end
    end

    context 'a joint tenancy' do
      it 'should have more than one contact' do
        contacts = tenancy_gateway.get_contacts_for(tenancy_ref: 'FAKE/02')
        expect(contacts.size).to eq(2)
        contacts.each { |c| expect(c).to be_instance_of(Hackney::Income::Domain::Contact) }
      end
    end

    context 'in a staging environment' do
      before do
        stub_request(:get, 'https://example.com/api/tenancies/FAKE%2F01/contacts')
          .to_return(body: stub_single_response.to_json)

        allow(Rails.env).to receive(:staging?).and_return(true)
      end

      it 'should not return any contact data at all' do
        contacts = tenancy_gateway.get_contacts_for(tenancy_ref: 'FAKE/01')
        expect(contacts).to eq([])
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

def generate_contact
  {
    contact_id: Faker::Lorem.characters(8),
    email_address: Faker::Internet.email,
    uprn: 0,
    address_line1: Faker::Address.building_number,
    address_line2: Faker::Address.street_address,
    address_line3: Faker::Address.city,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    full_name: Faker::Name.name,
    larn: Faker::Lorem.characters(8),
    telephone1: Faker::PhoneNumber.phone_number,
    telephone2: Faker::PhoneNumber.cell_phone,
    telephone3: nil,
    cautionary_alert: false,
    property_cautionary_alert: false,
    house_ref: Faker::Lorem.characters(8),
    title: Faker::Name.prefix,
    full_address_display: Faker::Address.full_address,
    full_address_search: Faker::Address.full_address,
    post_code: Faker::Address.postcode,
    date_of_birth: Faker::Date.birthday(18, 65),
    hackney_homes_id: Faker::Lorem.characters(8)
  }
end

def generate_contacts_response(contacts)
  {
    data:
    {
      contacts: contacts
    },
    statusCode: 0,
    error: {
      isValid: true,
      errors:
      [
        {
          message: '',
          code: ''
        }
      ],
      validationErrors:
      [
        {
          message: '',
          fieldName: ''
        }
      ]
    }
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
