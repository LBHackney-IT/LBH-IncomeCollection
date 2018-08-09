describe Hackney::Income::LessDangerousTenancyGateway do
  let(:tenancy_gateway) { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }

  context 'when retrieving a list of tenancies assigned to the current user' do
    let(:stub_tenancy_response) do
      {
        tenancies:
        [
          {
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
            }
          },
          {
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
            }
          }
        ]
      }
    end

    before do
      stub_request(:get, 'https://example.com/api/tenancies?tenancy_refs%5B%5D=FAKE/01&tenancy_refs%5B%5D=FAKE/02')
        .to_return(body: stub_tenancy_response.to_json)
    end

    subject { tenancy_gateway.get_tenancies_list(refs: ['FAKE/01', 'FAKE/02']) }

    let(:expected_first_tenancy) { stub_tenancy_response[:tenancies][0] }
    let(:expected_second_tenancy) { stub_tenancy_response[:tenancies][1] }

    it 'should return a tenancy for each reference given' do
      expect(subject.length).to eq(2)
    end

    it 'should include tenancy refs' do
      expect(subject[0].ref).to eq(expected_first_tenancy[:ref])
      expect(subject[1].ref).to eq(expected_second_tenancy[:ref])
    end

    it 'should include balances' do
      expect(subject[0].current_balance).to eq(expected_first_tenancy[:current_balance])
      expect(subject[1].current_balance).to eq(expected_second_tenancy[:current_balance])
    end

    it 'should include current agreement status' do
      expect(subject[0].current_arrears_agreement_status).to eq(expected_first_tenancy[:current_arrears_agreement_status])
      expect(subject[1].current_arrears_agreement_status).to eq(expected_second_tenancy[:current_arrears_agreement_status])
    end

    it 'should include latest action code' do
      expect(subject[0].latest_action_code).to eq(expected_first_tenancy[:latest_action][:code])
      expect(subject[1].latest_action_code).to eq(expected_second_tenancy[:latest_action][:code])
    end

    it 'should include latest action date' do
      expect(subject[0].latest_action_date).to eq(expected_first_tenancy[:latest_action][:date].strftime('%Y-%m-%d'))
      expect(subject[1].latest_action_date).to eq(expected_second_tenancy[:latest_action][:date].strftime('%Y-%m-%d'))
    end

    it 'should include basic contact details - name' do
      expect(subject[0].primary_contact_name).to eq(expected_first_tenancy[:primary_contact][:name])
      expect(subject[1].primary_contact_name).to eq(expected_second_tenancy[:primary_contact][:name])
    end

    it 'should include basic contact details - short address' do
      expect(subject[0].primary_contact_short_address).to eq(expected_first_tenancy[:primary_contact][:short_address])
      expect(subject[1].primary_contact_short_address).to eq(expected_second_tenancy[:primary_contact][:short_address])
    end

    it 'should include basic contact details - postcode' do
      expect(subject[0].primary_contact_postcode).to eq(expected_first_tenancy[:primary_contact][:postcode])
      expect(subject[1].primary_contact_postcode).to eq(expected_second_tenancy[:primary_contact][:postcode])
    end
  end

  context 'when receiving details of a single tenancy' do
    let(:stub_tenancy_response) do
      {
        tenancy_details:
        {
          ref: Faker::Lorem.characters(8),
          current_arrears_agreement_status: Faker::Lorem.characters(3),
          primary_contact_name: Faker::Name.first_name,
          primary_contact_long_address: Faker::Address.street_address,
          primary_contact_postcode: Faker::Lorem.word
        },
        latest_action_diary_events: Array.new(5) { action_diary_event },
        latest_arrears_agreements: Array.new(5) { arrears_agreement }
      }
    end

    before do
      stub_request(:get, 'https://example.com/api/tenancies/FAKE/01')
        .to_return(body: stub_tenancy_response.to_json)
    end

    subject { tenancy_gateway.get_tenancy(tenancy_ref: 'FAKE/01') }
    let(:expected_details) { stub_tenancy_response.fetch(:tenancy_details) }

    it 'should return a single tenancy matching the reference given' do
      expect(subject).to be_instance_of(Hackney::Income::Domain::Tenancy)
      expect(subject.ref).to eq(expected_details.fetch(:ref))
    end

    it 'should include the contact details and current state of the account' do
      expect(subject.current_arrears_agreement_status).to eq(expected_details.fetch(:current_arrears_agreement_status))
      expect(subject.primary_contact_name).to eq(expected_details.fetch(:primary_contact_name))
      expect(subject.primary_contact_long_address).to eq(expected_details.fetch(:primary_contact_long_address))
      expect(subject.primary_contact_postcode).to eq(expected_details.fetch(:primary_contact_postcode))
    end

    let(:expected_actions) { stub_tenancy_response.fetch(:latest_action_diary_events) }
    let(:expected_agreements) { stub_tenancy_response.fetch(:latest_arrears_agreements) }

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
  expect(expected.fetch(:balance)).to eq(actual.balance)
  expect(expected.fetch(:code)).to eq(actual.code)
  expect(expected.fetch(:type)).to eq(actual.type)
  expect(expected.fetch(:date).strftime('%Y-%m-%d')).to eq(actual.date)
  expect(expected.fetch(:comment)).to eq(actual.comment)
  expect(expected.fetch(:universal_housing_username)).to eq(actual.universal_housing_username)
end

def assert_agreement(expected, actual)
  expect(expected.fetch(:amount)).to eq(actual.amount)
  expect(expected.fetch(:breached)).to eq(actual.breached)
  expect(expected.fetch(:clear_by).strftime('%Y-%m-%d')).to eq(actual.clear_by)
  expect(expected.fetch(:frequency)).to eq(actual.frequency)
  expect(expected.fetch(:start_balance)).to eq(actual.start_balance)
  expect(expected.fetch(:start_date).strftime('%Y-%m-%d')).to eq(actual.start_date)
  expect(expected.fetch(:status)).to eq(actual.status)
end