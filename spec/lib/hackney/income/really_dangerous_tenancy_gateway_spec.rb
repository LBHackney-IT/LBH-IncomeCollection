describe Hackney::Income::ReallyDangerousTenancyGateway do
  let(:tenancy_gateway) { described_class.new(api_host: 'https://example.com') }

  before do
    stub_request(:get, 'https://example.com/v1/Accounts?referencenumber=1234567%2F01').
      to_return(body: {
        results: [{
          accountid: 'b64fc751-3a47-43bc-a804-f2ae55341ab5',
          tagReferenceNumber: '1234567/01',
          benefit: 0,
          propertyReferenceNumber: '00012345',
          currentBalance: -499.66,
          rent: 123.45,
          housingReferenceNumber: '1234567',
          directdebit: '1234567/0003',
          tenure: 'SEC',
          ListOfTenants: [{
            personNumber: '1',
            responsible: nil,
            title: 'Miss',
            forename: 'Buffy',
            surname: 'Summers'
          }],
          ListOfAddresses: [{
            postCode: 'E1 123',
            shortAddress: '123 Test Street',
            addressTypeCode: nil
          }]
        }]
      }.to_json)
  end

  context 'when retrieving a tenancy' do
    subject { tenancy_gateway.get_tenancy(tenancy_ref: '1234567/01') }

    it 'should include a real tenancy reference' do
      expect(subject).to include(ref: '1234567/01')
    end

    it 'should include a real current balance' do
      expect(subject).to include(current_balance: -499.66)
    end

    it 'should include some real contact details' do
      expect(subject.fetch(:primary_contact)).to include(
        first_name: 'Buffy',
        last_name: 'Summers',
        title: 'Miss'
      )
    end

    it 'should include some real address details' do
      expect(subject.fetch(:address)).to include(
        address_1: '123 Test Street',
        post_code: 'E1 123'
      )
    end

    it 'should include a **FAKE** tenancy type' do
      expect(subject).to include(type: 'Temporary Accommodation')
    end

    it 'should include a **FAKE** start date' do
      expect(subject).to include(start_date: '2018-01-01')
    end

    it 'should include some **FAKE** contact details' do
      expect(subject.fetch(:primary_contact)).to include(
        contact_number: '0208 123 1234',
        email_address: 'test@example.com'
      )
    end

    it 'should include some **FAKE** address details' do
      expect(subject.fetch(:address)).to include(
        address_2: 'Hackney',
        address_3: 'London',
        address_4: 'UK'
      )
    end

    it 'should include some **FAKE** transactions' do
      expect(subject.fetch(:transactions)).to include(
        type: 'payment',
        payment_method: 'Direct Debit',
        amount: '12.99',
        final_balance: '100.00',
        date: '2018-01-01'
      )
    end

    it 'should include some **FAKE** agreements' do
      expect(subject.fetch(:agreements)).to include(
        status: 'active',
        type: 'court_ordered',
        value: '10.99',
        frequency: 'weekly',
        created_date: '2017-11-01'
      )
    end

    it 'should include some **FAKE** arrears actions' do
      expect(subject.fetch(:arrears_actions)).to include(
        type: 'general_note',
        automated: false,
        user: { name: 'Rupert Giles' },
        date: '2018-01-01',
        description: '...'
      )
    end
  end
end
