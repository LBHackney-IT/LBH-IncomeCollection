describe Hackney::Income::LessDangerousTenancyGateway do
  let(:tenancy_gateway) { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }

  context 'when retrieving a list of tenancies assigned to the current user' do
    let(:stub_tenancy_response) do
      {
        tenancies:
        [
          {
            ref: Faker::Lorem.characters(8),
            current_balance: "¤#{Faker::Number.decimal(2)}",
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
      expect(subject[0].current_balance).to eq(expected_first_tenancy[:current_balance].delete('¤').to_f)
      expect(subject[1].current_balance).to eq(expected_second_tenancy[:current_balance].delete('¤').to_f)
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

  context 'when pulling prioritised tenancies' do
    let(:stub_tenancy_response) do
      [
        {
          ref: Faker::Lorem.characters(8),
          current_balance: "¤#{Faker::Number.decimal(2)}",
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
          score: Faker::Number.number(3),
          band: Faker::Lorem.characters(5),

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
        }
      ]
    end

    before do
      stub_request(:get, 'https://example.com/api/my-cases')
        .to_return(body: stub_tenancy_response.to_json)
    end

    subject { tenancy_gateway.temp_case_list }

    let(:expected_first_tenancy) { stub_tenancy_response[0] }
    let(:expected_second_tenancy) { stub_tenancy_response[1] }

    it 'should return a number of tenancies assigned to the user, determined by the API' do
      expect(subject.length).to eq(2)
    end

    it 'should include a score' do
      expect(subject[0].score).to eq(expected_first_tenancy[:priority_score])
      expect(subject[1].score).to eq(expected_second_tenancy[:priority_score])
    end

    it 'should include a band' do
      expect(subject[0].band).to eq(expected_first_tenancy[:priority_band])
      expect(subject[1].band).to eq(expected_second_tenancy[:priority_band])
    end

    it 'should include the contributions made to the score' do
      expect(subject[0].balance_contribution).to eq(expected_first_tenancy[:balance_contribution])
      expect(subject[0].days_in_arrears_contribution).to eq(expected_first_tenancy[:days_in_arrears_contribution])
      expect(subject[0].days_since_last_payment_contribution).to eq(expected_first_tenancy[:days_since_last_payment_contribution])
      expect(subject[0].payment_amount_delta_contribution).to eq(expected_first_tenancy[:payment_amount_delta_contribution])
      expect(subject[0].payment_date_delta_contribution).to eq(expected_first_tenancy[:payment_date_delta_contribution])
      expect(subject[0].number_of_broken_agreements_contribution).to eq(expected_first_tenancy[:number_of_broken_agreements_contribution])
      expect(subject[0].active_agreement_contribution).to eq(expected_first_tenancy[:active_agreement_contribution])
      expect(subject[0].broken_court_order_contribution).to eq(expected_first_tenancy[:broken_court_order_contribution])
      expect(subject[0].nosp_served_contribution).to eq(expected_first_tenancy[:nosp_served_contribution])
      expect(subject[0].active_nosp_contribution).to eq(expected_first_tenancy[:active_nosp_contribution])

      expect(subject[1].balance_contribution).to eq(expected_second_tenancy[:balance_contribution])
      expect(subject[1].days_in_arrears_contribution).to eq(expected_second_tenancy[:days_in_arrears_contribution])
      expect(subject[1].days_since_last_payment_contribution).to eq(expected_second_tenancy[:days_since_last_payment_contribution])
      expect(subject[1].payment_amount_delta_contribution).to eq(expected_second_tenancy[:payment_amount_delta_contribution])
      expect(subject[1].payment_date_delta_contribution).to eq(expected_second_tenancy[:payment_date_delta_contribution])
      expect(subject[1].number_of_broken_agreements_contribution).to eq(expected_second_tenancy[:number_of_broken_agreements_contribution])
      expect(subject[1].active_agreement_contribution).to eq(expected_second_tenancy[:active_agreement_contribution])
      expect(subject[1].broken_court_order_contribution).to eq(expected_second_tenancy[:broken_court_order_contribution])
      expect(subject[1].nosp_served_contribution).to eq(expected_second_tenancy[:nosp_served_contribution])
      expect(subject[1].active_nosp_contribution).to eq(expected_second_tenancy[:active_nosp_contribution])
    end

    it 'should include some useful info for displaying the priority contributions in a readable way' do
      expect(subject[0].days_in_arrears).to eq(expected_first_tenancy[:days_in_arrears])
      expect(subject[0].days_since_last_payment).to eq(expected_first_tenancy[:days_since_last_payment])
      expect(subject[0].payment_amount_delta).to eq(expected_first_tenancy[:payment_amount_delta])
      expect(subject[0].payment_date_delta).to eq(expected_first_tenancy[:payment_date_delta])
      expect(subject[0].number_of_broken_agreements).to eq(expected_first_tenancy[:number_of_broken_agreements])
      expect(subject[0].broken_court_order).to eq(expected_first_tenancy[:broken_court_order])
      expect(subject[0].nosp_served).to eq(expected_first_tenancy[:nosp_served])
      expect(subject[0].active_nosp).to eq(expected_first_tenancy[:active_nosp])

      expect(subject[1].days_in_arrears).to eq(expected_second_tenancy[:days_in_arrears])
      expect(subject[1].days_since_last_payment).to eq(expected_second_tenancy[:days_since_last_payment])
      expect(subject[1].payment_amount_delta).to eq(expected_second_tenancy[:payment_amount_delta])
      expect(subject[1].payment_date_delta).to eq(expected_second_tenancy[:payment_date_delta])
      expect(subject[1].number_of_broken_agreements).to eq(expected_second_tenancy[:number_of_broken_agreements])
      expect(subject[1].broken_court_order).to eq(expected_second_tenancy[:broken_court_order])
      expect(subject[1].nosp_served).to eq(expected_second_tenancy[:nosp_served])
      expect(subject[1].active_nosp).to eq(expected_second_tenancy[:active_nosp])
    end
  end

  context 'when receiving details of a single tenancy' do
    let(:stub_tenancy_response) do
      {
        tenancy_details:
        {
          ref: Faker::Lorem.characters(8),
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

    context 'in a staging environment' do
      let(:stub_tenancy_response) do
        {
          tenancies:
          [
            {
              ref:'12345',
              current_balance: "¤#{Faker::Number.decimal(2)}",
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
              score: Faker::Number.number(3),
              band: Faker::Lorem.characters(5)
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
              },
              score: Faker::Number.number(3),
              band: Faker::Lorem.characters(5)
            }
          ]
        }
      end

      let(:stub_single_tenancy) do
        {
          tenancy_details:
          {
            ref:'12345',
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
        stub_request(:get, 'https://example.com/api/tenancies?tenancy_refs%5B%5D=FAKE/01&tenancy_refs%5B%5D=FAKE/02')
          .to_return(body: stub_tenancy_response.to_json)

        stub_request(:get, 'https://example.com/api/my-cases')
          .to_return(body: stub_tenancy_response[:tenancies].to_json)

        stub_request(:get, 'https://example.com/api/tenancies/FAKE%2F01')
          .to_return(body: stub_single_tenancy.to_json)

        allow(Rails.env).to receive(:staging?).and_return(true)
      end

      let(:listed_tenancies) { tenancy_gateway.get_tenancies_list(refs: ['FAKE/01', 'FAKE/02']) }
      let(:prioritised_tenancies) { tenancy_gateway.temp_case_list }
      let(:single_tenancy) { tenancy_gateway.get_tenancy(tenancy_ref: 'FAKE/01') }

      let(:seeded_tenancy) do
        {
          primary_contact_name: "Ms. Trent Friesen",
          primary_contact_short_address: "8602 Maggio Hollow",
          primary_contact_postcode: "22677"
        }
      end

      let(:seeded_prioritised_tenancy) do
        {
          primary_contact_name: "Ms. Stanford Ernser",
          primary_contact_short_address: "129 Cruickshank Plains",
          primary_contact_postcode: "36777-8717"
        }
      end

      let(:seeded_single_tenancy) do
        {
          primary_contact_name: "Ms. Michele Dickinson",
          primary_contact_long_address: "3677 Berge Stravenue",
          primary_contact_postcode: "27403-5731"
        }
      end

      it 'should obfuscate the name, address and postcode for each list item' do
        expect(listed_tenancies.primary_contact_short_address).to eq(seeded_tenancy[:primary_contact_short_address])
        expect(listed_tenancies.primary_contact_name).to eq(seeded_tenancy[:primary_contact_name])
        expect(listed_tenancies.primary_contact_postcode).to eq(seeded_tenancy[:primary_contact_postcode])
      end

      it 'should obfuscate the name, address and postcode for each prioritised list item' do
        expect(prioritised_tenancies[0].primary_contact_short_address).to eq(seeded_prioritised_tenancy[:primary_contact_short_address])
        expect(prioritised_tenancies[0].primary_contact_name).to eq(seeded_prioritised_tenancy[:primary_contact_name])
        expect(prioritised_tenancies[0].primary_contact_postcode).to eq(seeded_prioritised_tenancy[:primary_contact_postcode])
      end

      it 'should obfuscate the name, address and postcode for each single tenancy item' do
        expect(single_tenancy.primary_contact_long_address).to eq(seeded_single_tenancy[:primary_contact_long_address])
        expect(single_tenancy.primary_contact_name).to eq(seeded_single_tenancy[:primary_contact_name])
        expect(single_tenancy.primary_contact_postcode).to eq(seeded_single_tenancy[:primary_contact_postcode])
      end
    end
  end
end

def action_diary_event
  {
    balance: "¤#{Faker::Number.decimal(2)}",
    code: Faker::Lorem.characters(3),
    type: Faker::Lorem.characters(3),
    date: Faker::Date.forward(100),
    comment: Faker::Lovecraft.sentences(2),
    universal_housing_username: Faker::Name.first_name
  }
end

def arrears_agreement
  {
    amount: "¤#{Faker::Number.decimal(2)}",
    breached: Faker::Lorem.characters(3),
    clear_by: Faker::Date.forward(100),
    frequency: Faker::Lorem.characters(5),
    start_balance: Faker::Number.decimal(2),
    start_date: Faker::Date.forward(10),
    status: Faker::Lorem.characters(3)
  }
end

def assert_action_diary_event(expected, actual)
  expect(expected.fetch(:balance).delete('¤').to_f).to eq(actual.balance)
  expect(expected.fetch(:code)).to eq(actual.code)
  expect(expected.fetch(:type)).to eq(actual.type)
  expect(expected.fetch(:date).strftime('%Y-%m-%d')).to eq(actual.date)
  expect(expected.fetch(:comment)).to eq(actual.comment)
  expect(expected.fetch(:universal_housing_username)).to eq(actual.universal_housing_username)
end

def assert_agreement(expected, actual)
  expect(expected.fetch(:amount).delete('¤').to_f).to eq(actual.amount)
  expect(expected.fetch(:breached)).to eq(actual.breached)
  expect(expected.fetch(:clear_by).strftime('%Y-%m-%d')).to eq(actual.clear_by)
  expect(expected.fetch(:frequency)).to eq(actual.frequency)
  expect(expected.fetch(:start_balance)).to eq(actual.start_balance)
  expect(expected.fetch(:start_date).strftime('%Y-%m-%d')).to eq(actual.start_date)
  expect(expected.fetch(:status)).to eq(actual.status)
end
