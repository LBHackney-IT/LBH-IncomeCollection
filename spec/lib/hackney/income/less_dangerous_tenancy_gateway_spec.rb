describe Hackney::Income::LessDangerousTenancyGateway do
  let(:tenancy_gateway) { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }

  context 'when retrieving a list of tenancies assigned to the current user' do
    let(:stub_tenancy_response) do
      {
        tenancies:
        [
          {
            ref: 'FAKE/01',
            current_balance: '99.00',
            current_arrears_agreement_status: '100',
            latest_action:
            {
              code: 'LETTER1',
              date: '2016-08-25 16:58:00Z'
            },
            primary_contact:
            {
              name: 'Ben Affleck',
              short_address: 'Phantoms',
              postcode: 'Rotten'
            }
          },
          {
            ref: 'FAKE/02',
            current_balance: '209.00',
            current_arrears_agreement_status: '101',
            latest_action:
            {
              code: 'LETTER2',
              date: '2016-08-24 16:58:00Z'
            },
            primary_contact:
            {
              name: 'Matt Damon',
              short_address: 'Good Will Hunting',
              postcode: 'Fresh'
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

    it 'should return a tenancy for each reference given' do
      expect(subject.length).to eq(2)
    end

    it 'should include tenancy refs' do
      expect(subject[0].ref).to eq('FAKE/01')
      expect(subject[1].ref).to eq('FAKE/02')
    end

    it 'should include balances' do
      expect(subject[0].current_balance).to eq('99.00')
      expect(subject[1].current_balance).to eq('209.00')
    end

    it 'should include current agreement status' do
      expect(subject[0].current_arrears_agreement_status).to eq('100')
      expect(subject[1].current_arrears_agreement_status).to eq('101')
    end

    it 'should include latest action code' do
      expect(subject[0].latest_action_code).to eq('LETTER1')
      expect(subject[1].latest_action_code).to eq('LETTER2')
    end

    it 'should include latest action date' do
      expect(subject[0].latest_action_date).to eq('2016-08-25 16:58:00Z')
      expect(subject[1].latest_action_date).to eq('2016-08-24 16:58:00Z')
    end

    it 'should include basic contact details - name' do
      expect(subject[0].primary_contact_name).to eq('Ben Affleck')
      expect(subject[1].primary_contact_name).to eq('Matt Damon')
    end

    it 'should include basic contact details - short address' do
      expect(subject[0].primary_contact_short_address).to eq('Phantoms')
      expect(subject[1].primary_contact_short_address).to eq('Good Will Hunting')
    end

    it 'should include basic contact details - postcode' do
      expect(subject[0].primary_contact_postcode).to eq('Rotten')
      expect(subject[1].primary_contact_postcode).to eq('Fresh')
    end
  end
end
