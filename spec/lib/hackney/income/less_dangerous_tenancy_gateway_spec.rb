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
end
