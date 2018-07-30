xdescribe Hackney::Income::ReallyDangerousTenancyGateway do
  let(:tenancy_gateway) { described_class.new(api_host: 'https://example.com/api') }
  let(:found_names) { subject.map { |tenancy| tenancy.dig(:primary_contact, :first_name) } }

  context 'when retrieving a tenancy' do
    let(:stub_tenancy_response) do
      {
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
          ListOfTenants: [
            {
              personNumber: nil,
              responsible: nil,
              title: nil,
              forename: nil,
              surname: nil
            },
            {
              personNumber: '1',
              responsible: nil,
              title: 'Miss',
              forename: 'Buffy',
              surname: 'Summers'
            }
          ],
          ListOfAddresses: [{
            postCode: 'E1 123',
            shortAddress: '123 Test Street',
            addressTypeCode: nil
          }]
        }]
      }
    end

    before do
      stub_request(:get, 'https://example.com/api/tenancies?tenancy_refs[0]=FAKE/01,tenancy_refs[1]=FAKE/02')
        .to_return(body: stub_tenancy_response.to_json)
    end

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

    it 'should include a real tenancy type' do
      expect(subject).to include(type: 'SEC')
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

    context 'and the tenancy is a Hackney developer' do
      let(:tenancy_gateway) { described_class.new(api_host: 'https://example.com/api', include_developer_data: true) }
      subject { tenancy_gateway.get_tenancy(tenancy_ref: '0000001/FAKE') }

      it 'should return the tenancy' do
        expect(subject.dig(:primary_contact, :first_name)).to eq('Richard')
      end
    end
  end

  context 'when retrieving all tenancies in arrears' do
    let(:base_stub_tenancies_in_arrears_response) do
      {
        results: [
          create_tenancy_object(
            tagReferenceNumber: '012345/01',
            currentBalance: 1168.69,
            ListOfTenants: [
              create_tenant_object(
                personNumber: nil,
                title: nil,
                forename: nil,
                surname: nil
              ),
              create_tenant_object(
                personNumber: '1',
                title: 'Mr',
                forename: 'Steven',
                surname: 'Leighton'
              ),
              create_tenant_object(
                personNumber: '2',
                title: 'Mrs',
                forename: 'Rashmi',
                surname: 'Shetty'
              )
            ],
            ListOfAddresses: [
              create_address_object(
                postCode: 'E1 1AB',
                shortAddress: '1 Awesome Road'
              )
            ]
          ),
          create_tenancy_object(
            tagReferenceNumber: '0456789/01',
            currentBalance: 727.86,
            ListOfTenants: [
              create_tenant_object(
                personNumber: nil,
                title: nil,
                forename: nil,
                surname: nil
              ),
              create_tenant_object(
                personNumber: '1',
                title: 'Mr',
                forename: 'Rory',
                surname: 'MacDonald'
              )
            ],
            ListOfAddresses: [
              create_address_object(
                postCode: 'E1 1ZE',
                shortAddress: '12 Great Road'
              )
            ]
          )
        ]
      }
    end

    let(:stub_tenancies_in_arrears_response) { base_stub_tenancies_in_arrears_response }

    before do
      stub_request(:get, 'https://example.com/api/v1/tenancies')
        .to_return(body: stub_tenancies_in_arrears_response.to_json)
    end

    subject { tenancy_gateway.get_tenancies_in_arrears }
    alias_method :get_tenancies, :subject

    it 'should return a list of tenancies' do
      expect(subject).to eq([
        {
          primary_contact: {
            first_name: 'Steven',
            last_name: 'Leighton',
            title: 'Mr'
          },
          address_1: '1 Awesome Road',
          post_code: 'E1 1AB',
          tenancy_ref: '012345/01',
          current_balance: '1168.69'
        },
        {
          primary_contact: {
            first_name: 'Rory',
            last_name: 'MacDonald',
            title: 'Mr'
          },
          address_1: '12 Great Road',
          post_code: 'E1 1ZE',
          tenancy_ref: '0456789/01',
          current_balance: '727.86'
        }
      ])
    end

    it 'should not include developer data' do
      expect(found_names).to_not include('Richard')
    end

    context 'and there is a tenancy included which has no valid person details' do
      let(:stub_tenancies_in_arrears_response) do
        {
          results: [
            create_tenancy_object(tagReferenceNumber: '000001/01'),
            create_tenancy_object(
              tagReferenceNumber: '000002/01',
              ListOfTenants: [
                create_tenant_object(personNumber: nil)
              ]
            )
          ]
        }
      end

      it 'should log a warning message' do
        allow(Rails.logger).to receive(:warn)
        expect(Rails.logger).to receive(:warn).with('Tenancy "000002/01" has no appropriate contact')

        get_tenancies
      end

      it 'should ignore that tenancy' do
        expect(subject.count).to eq(1)
      end
    end

    context 'and developer data is required' do
      let(:tenancy_gateway) do
        described_class.new(api_host: 'https://example.com/api', include_developer_data: true)
      end

      it 'should include Hackney developer data' do
        expect(found_names).to include('Richard')
      end
    end
  end

  def create_tenancy_object(options = {})
    options.reverse_merge(
      accountid: '0cb73207-123e-e711-8101-70106faa1531',
      tagReferenceNumber: '543210/01',
      benefit: 0,
      propertyReferenceNumber: '00046464',
      currentBalance: 1168.69,
      rent: 121.31,
      housingReferenceNumber: '543210',
      directdebit: nil,
      tenure: 'SEC',
      ListOfTenants: [
        create_tenant_object
      ],
      ListOfAddresses: [
        create_address_object
      ]
    )
  end

  def create_tenant_object(options = {})
    options.reverse_merge(
      personNumber: '1',
      responsible: nil,
      title: 'Ms',
      forename: 'Dana',
      surname: 'Scully'
    )
  end

  def create_address_object(options = {})
    options.reverse_merge(
      postCode: 'E1 1AB',
      shortAddress: '1 Awesome Road',
      addressTypeCode: nil
    )
  end
end
