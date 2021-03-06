require 'rails_helper'

describe Hackney::Income::TenancyGateway do
  let(:tenancy_gateway) { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }

  context 'when pulling prioritised tenancies' do
    let(:page_number) { Faker::Number.number(digits: 2).to_i }
    let(:number_per_page) { Faker::Number.number(digits: 2).to_i }
    let(:paused) { false }
    let(:full_patch) { false }
    let(:upcoming_court_dates) { false }
    let(:upcoming_evictions) { false }
    let(:patch_code) { Faker::Lorem.characters(number: 3) }
    let(:filter_params) do
      Hackney::Income::FilterParams::ListCasesParams.new(
        page: page_number,
        count_per_page: number_per_page,
        paused: paused,
        full_patch: full_patch,
        upcoming_court_dates: upcoming_court_dates,
        upcoming_evictions: upcoming_evictions,
        patch_code: patch_code
      )
    end

    subject do
      tenancy_gateway.get_tenancies(
        filter_params: filter_params
      )
    end

    context 'when the api is returning errors' do
      before do
        stub_request(:get, 'https://example.com/api/v1/cases')
        .with(query: hash_including({}))
        .to_return(status: [500, 'oh no!'])
      end

      it 'should raise a IncomeApiError' do
        expect { subject }.to raise_error(Exceptions::IncomeApiError, "[Income API error: Received 500 response] when trying to get_tenancies for Params '#{filter_params.to_params.inspect}'")
      end
    end

    context 'when the api is running' do
      before do
        stub_request(:get, 'https://example.com/api/v1/cases')
          .with(query: hash_including({}))
          .to_return(body: stub_response.to_json)
      end

      let(:stub_response) { { cases: stub_tenancies, number_of_pages: number_of_pages } }
      let(:number_of_pages) { Faker::Number.number(digits: 3).to_i }
      let(:stub_tenancies) do
        Array.new(Faker::Number.number(digits: 2).to_i).map { example_tenancy_list_response_item }
      end

      it 'should look up tenancies for the user id and page params passed in' do
        subject

        request = a_request(:get, 'https://example.com/api/v1/cases').with(
          headers: { 'X-Api-Key' => 'skeleton' },
          query: {
            'page_number' => page_number,
            'number_per_page' => number_per_page,
            'is_paused' => paused,
            'full_patch' => full_patch,
            'upcoming_court_dates' => upcoming_court_dates,
            'upcoming_evictions' => upcoming_evictions,
            'patch' => patch_code
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
          [example_tenancy_list_response_item(current_balance: { value: 5675.89, currency: 'GBP' })]
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
          expect(subject.tenancies.first.nosp_served_contribution).to eq(expected_tenancy[:nosp_served_contribution])
          expect(subject.tenancies.first.active_nosp_contribution).to eq(expected_tenancy[:active_nosp_contribution])
        end

        it 'should include some useful info for displaying the priority contributions in a readable way' do
          expect(subject.tenancies.first.days_in_arrears).to eq(expected_tenancy[:days_in_arrears])
          expect(subject.tenancies.first.days_since_last_payment).to eq(expected_tenancy[:days_since_last_payment])
          expect(subject.tenancies.first.payment_amount_delta).to eq(expected_tenancy[:payment_amount_delta])
          expect(subject.tenancies.first.payment_date_delta).to eq(expected_tenancy[:payment_date_delta])
          expect(subject.tenancies.first.nosp_served).to eq(expected_tenancy[:nosp_served])
          expect(subject.tenancies.first.active_nosp).to eq(expected_tenancy[:active_nosp])
        end

        it 'should include balances, converting those given as currencies' do
          expect(subject.tenancies.first.current_balance).to eq(5_675.89)
        end

        it 'should include the courtdate for the case' do
          expect(subject.tenancies.first.courtdate).to eq(expected_tenancy[:courtdate].strftime('%Y-%m-%d'))
        end

        it 'should include the eviction_date for the case' do
          expect(subject.tenancies.first.eviction_date).to eq(expected_tenancy[:eviction_date].strftime('%Y-%m-%d'))
        end

        it 'should include the pause reason' do
          expect(subject.tenancies.first.pause_reason).to eq(expected_tenancy[:pause][:reason])
        end

        it 'should include the pause comment' do
          expect(subject.tenancies.first.pause_comment).to eq(expected_tenancy[:pause][:comment])
        end

        it 'should include the pause end date' do
          expect(subject.tenancies.first.is_paused_until).to eq(expected_tenancy[:pause][:until].strftime('%Y-%m-%d'))
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

        it 'includes the classification of the case' do
          expect(subject.tenancies.first.classification).to eq(expected_tenancy[:classification])
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
            primary_contact_name: 'Mr. Emery McKenzie',
            primary_contact_short_address: '7567 Feest Ports',
            primary_contact_postcode: '09586-3717'
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
            current_balance: {
              value: 4234.56,
              currency_code: 'GBP'
            }
          }
        )
      end

      before do
        stub_request(:get, 'https://example.com/api/v1/tenancies/FAKE%2F01')
          .to_return(body: stub_response.to_json)

        stub_request(:get, 'https://example.com/api/v1/tenancies/FAKE%2F02')
          .to_return(body: triangulated_stub_tenancy_response.to_json)
      end

      subject { tenancy_gateway.get_tenancy(tenancy_ref: 'FAKE/01') }
      let(:expected_details) { stub_response.fetch(:tenancy_details) }

      it 'should return a single tenancy matching the reference given with converted currencies' do
        expect(subject).to be_instance_of(Hackney::Income::Domain::Tenancy)
        expect(subject.payment_ref).to eq(expected_details.fetch(:payment_ref))
        expect(subject.ref).to eq(expected_details.fetch(:ref))
        expect(subject.start_date).to eq(expected_details.fetch(:start_date))
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
        expect(tenancy.current_balance).to eq(expected_details.fetch(:current_balance).fetch(:value))
      end

      context 'when api is down an error' do
        before do
          stub_request(:get, 'https://example.com/api/v1/tenancies/fail%2F01').to_return(status: 503)
        end

        it 'should throw an exception' do
          expect do
            tenancy_gateway.get_tenancy(tenancy_ref: 'fail/01')
          end.to raise_error(Exceptions::TenancyApiError, "[Tenancy API error: Received 503 response] when trying to tenancy using ref 'fail/01'")
        end
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

      context 'in a staging environment' do
        let(:stub_response) do
          {
            tenancy_details:
            {
              ref: '12345',
              payment_ref: nil,
              tenure: Faker::Lorem.characters(number: 3),
              rent: "¤#{Faker::Number.decimal(l_digits: 2)}",
              start_date: Faker::Date.backward(days: 14).to_s,
              service: "¤#{Faker::Number.decimal(l_digits: 2)}",
              other_charge: "¤#{Faker::Number.decimal(l_digits: 2)}",
              current_arrears_agreement_status: Faker::Lorem.characters(number: 3),
              current_balance: {
                value: "¤#{Faker::Number.decimal(l_digits: 2)}",
                currency_code: 'GBP'
              },
              primary_contact_name: Faker::Name.first_name,
              primary_contact_long_address: Faker::Address.street_address,
              primary_contact_postcode: Faker::Lorem.word
            },
            latest_action_diary_events: Array.new(5) { action_diary_event },
            latest_arrears_agreements: Array.new(5) { arrears_agreement }
          }
        end

        before do
          stub_request(:get, 'https://example.com/api/v1/tenancies/FAKE%2F01')
            .to_return(body: stub_response.to_json)

          allow(Rails.env).to receive(:staging?).and_return(true)
        end

        let(:single_tenancy) { tenancy_gateway.get_tenancy(tenancy_ref: 'FAKE/01') }
        let(:expected_tenancy) do
          {
            primary_contact_name: 'Ms. Sara Schowalter',
            primary_contact_long_address: '3161 Gutkowski Loop',
            primary_contact_postcode: '76029-1267'
          }
        end

        it 'should obfuscate the name, address and postcode for each single tenancy item' do
          expect(single_tenancy.primary_contact_long_address).to eq(expected_tenancy[:primary_contact_long_address])
          expect(single_tenancy.primary_contact_name).to eq(expected_tenancy[:primary_contact_name])
          expect(single_tenancy.primary_contact_postcode).to eq(expected_tenancy[:primary_contact_postcode])
          expect(subject.payment_ref).to eq(nil)
        end
      end
    end

    context 'getting contact details for a tenancy ref' do
      let(:stub_single_response) { generate_contacts_response([generate_contact]) }

      context 'a single tenant' do
        before do
          stub_request(:get, 'https://example.com/api/v1/tenancies/FAKE%2F01/contacts')
            .to_return(body: stub_single_response.to_json)
        end

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
          expect(contacts[0].responsible).to eq(expected_contact.fetch(:responsible))
        end
      end

      context 'a joint tenancy' do
        let(:stub_joint_response) { generate_contacts_response(2.times.to_a.map { generate_contact }) }

        before do
          stub_request(:get, 'https://example.com/api/v1/tenancies/FAKE%2F02/contacts')
            .to_return(body: stub_joint_response.to_json)
        end

        it 'should have more than one contact' do
          contacts = tenancy_gateway.get_contacts_for(tenancy_ref: 'FAKE/02')
          expect(contacts.size).to eq(2)
          contacts.each { |c| expect(c).to be_instance_of(Hackney::Income::Domain::Contact) }
        end
      end

      context 'in a staging environment' do
        before do
          stub_request(:get, 'https://example.com/api/v1/tenancies/FAKE%2F01/contacts')
            .to_return(body: stub_single_response.to_json)

          allow(Rails.env).to receive(:staging?).and_return(true)
        end

        it 'should not return random contact data' do
          contact = tenancy_gateway.get_contacts_for(tenancy_ref: 'FAKE/01').first
          true_contact = stub_single_response[:data][:contacts].first

          expect(contact.first_name).not_to eq(true_contact[:first_name])
          expect(contact.last_name).not_to eq(true_contact[:last_name])
          expect(contact.full_name).not_to eq(true_contact[:full_name])
          expect(contact.email_address).not_to eq(true_contact[:email_address])
          expect(contact.address_line_1).not_to eq(true_contact[:address_line_1])
          expect(contact.address_line_2).not_to eq(true_contact[:address_line_2])
          expect(contact.address_line_3).not_to eq(true_contact[:address_line_3])
          expect(contact.telephone_1).not_to eq(true_contact[:telephone_1])
          expect(contact.telephone_2).not_to eq(true_contact[:telephone_2])
          expect(contact.post_code).not_to eq(true_contact[:post_code])
          expect(contact.date_of_birth).not_to eq(true_contact[:date_of_birth])
        end
      end

      context 'contact data is missing or fragmented' do
        let(:stub_empty_response_1) { generate_contacts_response([]) }
        let(:stub_empty_response_2) { generate_contacts_response(nil) }

        before do
          stub_request(:get, 'https://example.com/api/v1/tenancies/FAKE%2F03/contacts')
            .to_return(body: stub_empty_response_1.to_json)
          stub_request(:get, 'https://example.com/api/v1/tenancies/FAKE%2F04/contacts')
            .to_return(body: stub_empty_response_2.to_json)
        end

        it 'should return nothing if no contact was available' do
          contacts = tenancy_gateway.get_contacts_for(tenancy_ref: 'FAKE/03')
          expect(contacts).to eq([])
        end

        it 'should return nothing if nil was received' do
          contacts = tenancy_gateway.get_contacts_for(tenancy_ref: 'FAKE/04')
          expect(contacts).to eq([])
        end
      end
    end
  end

  context 'when getting a case priority' do
    let(:nosp_served_date) { 3.months.ago }
    let(:case_priority) do
      {
        id: 1,
        tenancy_ref: '055593/01',
        priority_band: 'red',
        priority_score: 21_563,
        created_at: '2019-04-02T03=>26=>35.000Z',
        updated_at: '2019-09-16T16=>48=>29.410Z',
        balance_contribution: '517.0',
        days_in_arrears_contribution: '1689.0',
        days_since_last_payment_contribution: '214725.0',
        payment_amount_delta_contribution: '-900.0',
        payment_date_delta_contribution: '30.0',
        nosp_served_contribution: nil,
        active_nosp_contribution: nil,
        balance: '430.9',
        days_in_arrears: 1126,
        days_since_last_payment: 1227,
        payment_amount_delta: '-900.0',
        payment_date_delta: 6,
        nosp_served: false,
        active_nosp: false,
        assigned_user_id: 1,
        is_paused_until: nil,
        pause_reason: nil,
        pause_comment: nil,
        case_id: 7250,
        classification: 'send_letter_one',
        assigned_user: {
          id: 1,
          provider_uid: 'AIHAIEROUAWEB',
          provider: 'azureactivedirectory',
          name: 'Elena Vilimaite',
          email: 'Elena.Vilimaite@hackney.gov.uk',
          first_name: 'Elena',
          last_name: 'Vilimaite',
          provider_permissions: 'true',
          role: 'base_user'
        },
        nosp: {
          active: true,
          expires_date: (nosp_served_date + 28.days).iso8601(3),
          in_cool_off_period: false,
          served_date: nosp_served_date.iso8601(3),
          valid_until_date: (nosp_served_date + 28.days + 52.weeks).iso8601(3),
          valid: true
        }
      }
    end

    subject do
      tenancy_gateway.get_case_priority(tenancy_ref: case_priority[:tenancy_ref])
    end

    context 'when there is an assigned case priority' do
      before do
        stub_request(:get, "https://example.com:443/api/v1/tenancies/#{ERB::Util.url_encode(case_priority[:tenancy_ref])}")
          .to_return(status: [200], body: case_priority.to_json)
      end

      it 'gets a case priority' do
        expect(subject).to eq(case_priority)
      end
    end

    context 'when there is no case priority' do
      before do
        stub_request(:get, "https://example.com:443/api/v1/tenancies/#{ERB::Util.url_encode(case_priority[:tenancy_ref])}")
          .to_return(status: [404])
      end

      it 'gracefully returns empty hash' do
        expect(subject).to eq({})
      end
    end

    context 'given api is down' do
      before do
        stub_request(:get, "https://example.com:443/api/v1/tenancies/#{ERB::Util.url_encode(case_priority[:tenancy_ref])}")
          .to_return(status: [500, 'oh no!'])
      end

      it 'get_tenancy_pause should raise a IncomeApiError' do
        expect { subject }.to raise_error(Exceptions::IncomeApiError, "[Income API error: Received 500 response] when trying to get_case_priority using 'https://example.com/api/v1/tenancies/#{ERB::Util.url_encode(case_priority[:tenancy_ref])}'")
      end
    end
  end

  context 'when updating a tenancy' do
    context 'unsuccessfully getting tenancy pause' do
      let(:tenancy_ref) { Faker::Lorem.characters(number: 6) }

      context 'given tenancy not found' do
        before do
          stub_request(:get, "https://example.com:443/api/v1/tenancies/#{tenancy_ref}/pause")
            .to_return(status: [404, 'oh no!'])
        end

        it 'should raise a IncomeApiError::NotFoundError' do
          expect do
            tenancy_gateway.get_tenancy_pause(tenancy_ref: tenancy_ref)
          end.to raise_error(Exceptions::IncomeApiError::NotFoundError, "[Income API error: Received 404 response] when trying to get_tenancy_pause with tenancy_ref: '#{tenancy_ref}'")
        end
      end

      context 'given api is down' do
        before do
          stub_request(:get, "https://example.com:443/api/v1/tenancies/#{tenancy_ref}/pause")
            .to_return(status: [500, 'oh no!'])
        end

        it 'get_tenancy_pause should raise a IncomeApiError' do
          expect do
            tenancy_gateway.get_tenancy_pause(tenancy_ref: tenancy_ref)
          end.to raise_error(Exceptions::IncomeApiError, "[Income API error: Received 500 response] when trying to get_tenancy_pause using '#{"https://example.com/api/v1/tenancies/#{tenancy_ref}/pause"}'")
        end
      end
    end

    context 'successfully get\'s tenancy pause' do
      let(:future_date_param) { '1990-10-20' }
      let(:tenancy_ref) { Faker::Lorem.characters(number: 6) }
      let(:pause_reason) { Faker::Lorem.sentence }
      let(:pause_comment) { Faker::Lorem.paragraph }

      before do
        stub_request(:get, "https://example.com:443/api/v1/tenancies/#{tenancy_ref}/pause")
          .to_return(body: {
            is_paused_until: future_date_param,
            pause_reason: pause_reason,
            pause_comment: pause_comment
          }.to_json)
      end

      it 'should return tenancy pause in as open struct' do
        expect(
          tenancy_gateway.get_tenancy_pause(tenancy_ref: tenancy_ref)
        ).to eq(
          is_paused_until: future_date_param,
          pause_reason: pause_reason,
          pause_comment: pause_comment
        )
      end
    end

    context 'successfully updates a tenancy' do
      let(:future_date_param) { Time.parse('1990-10-20') }
      let(:tenancy_ref) { Faker::Lorem.characters(number: 6) }
      let(:pause_reason) { Faker::Lorem.sentence }
      let(:pause_comment) { Faker::Lorem.paragraph }
      let(:username) { Faker::Name.name }
      let(:action_code) { Faker::Internet.slug }

      before do
        stub_request(:patch, "https://example.com/api/v1/tenancies/#{tenancy_ref}")
          .with(
            body: {
              'action_code' => action_code,
              'is_paused_until' => future_date_param,
              'pause_comment' => pause_comment,
              'pause_reason' => pause_reason,
              'username' => username
            }
          ).to_return(status: [204, :no_content])
      end

      it 'should return HTTPNoContent' do
        expect(
          tenancy_gateway.update_tenancy(
            tenancy_ref: tenancy_ref,
            is_paused_until_date: future_date_param,
            pause_reason: pause_reason,
            pause_comment: pause_comment,
            username: username,
            action_code: action_code
          )
        ).to be_instance_of(Net::HTTPNoContent)
      end
    end
  end
end

def action_diary_event
  {
    balance: Faker::Number.decimal(l_digits: 2),
    code: Faker::Lorem.characters(number: 3),
    type: Faker::Lorem.characters(number: 3),
    date: Faker::Date.forward(days: 100),
    comment: Faker::Books::Lovecraft.sentences(number: 2),
    universal_housing_username: Faker::Name.first_name
  }
end

def generate_contact
  {
    contact_id: Faker::Lorem.characters(number: 8),
    email_address: Faker::Internet.email,
    uprn: 0,
    address_line1: Faker::Address.building_number,
    address_line2: Faker::Address.street_address,
    address_line3: Faker::Address.city,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    full_name: Faker::Name.name,
    larn: Faker::Lorem.characters(number: 8),
    telephone1: Faker::PhoneNumber.phone_number,
    telephone2: Faker::PhoneNumber.cell_phone,
    telephone3: nil,
    cautionary_alert: false,
    property_cautionary_alert: false,
    house_ref: Faker::Lorem.characters(number: 8),
    title: Faker::Name.prefix,
    full_address_display: Faker::Address.full_address,
    full_address_search: Faker::Address.full_address,
    post_code: Faker::Address.postcode,
    date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 65),
    hackney_homes_id: Faker::Lorem.characters(number: 8),
    responsible: Faker::Number.between(from: 0, to: 1)
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
    amount: Faker::Number.decimal(l_digits: 2),
    breached: Faker::Lorem.characters(number: 3),
    clear_by: Faker::Date.forward(days: 100),
    frequency: Faker::Lorem.characters(number: 5),
    start_balance: Faker::Number.decimal(l_digits: 2),
    start_date: Faker::Date.forward(days: 10),
    status: Faker::Lorem.characters(number: 3)
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
    ref: Faker::Lorem.characters(number: 8),
    current_balance: {
      value: Faker::Number.decimal(l_digits: 2),
      currency: Faker::Currency.code
    },
    current_arrears_agreement_status: Faker::Lorem.characters(number: 3),
    latest_action:
    {
      code: Faker::Lorem.characters(number: 10),
      date: Faker::Date.forward(days: 100)
    },
    primary_contact:
    {
      name: Faker::Name.first_name,
      short_address: Faker::Address.street_address,
      postcode: Faker::Lorem.word
    },
    priority_score: Faker::Number.number(digits: 3),
    priority_band: Faker::Lorem.characters(number: 5),
    balance_contribution: Faker::Number.number(digits: 2),
    days_in_arrears_contribution: Faker::Number.number(digits: 2),
    days_since_last_payment_contribution: Faker::Number.number(digits: 2),
    payment_amount_delta_contribution: Faker::Number.number(digits: 2),
    payment_date_delta_contribution: Faker::Number.number(digits: 2),
    nosp_served_contribution: Faker::Number.number(digits: 2),
    active_nosp_contribution: Faker::Number.number(digits: 2),
    days_in_arrears: Faker::Number.number(digits: 2),
    days_since_last_payment: Faker::Number.number(digits: 2),
    payment_amount_delta: Faker::Number.number(digits: 2),
    payment_date_delta: Faker::Number.number(digits: 2),
    nosp_served: Faker::Number.between(from: 0, to: 1),
    active_nosp: Faker::Number.between(from: 0, to: 1),
    courtdate: Date.today,
    eviction_date: Date.today + 420,
    pause: {
      reason: Faker::Verb.past,
      comment: Faker::Lorem.words(number: 8),
      until: Date.today + 5.days
    },

    classification: 'send_letter_one'
  )
end

def example_single_tenancy_response(options = {})
  {
    tenancy_details: {
      payment_ref: Faker::Lorem.characters(number: 10),
      ref: Faker::Lorem.characters(number: 8),
      tenure: Faker::Lorem.characters(number: 3),
      rent: Faker::Number.decimal(l_digits: 5),
      start_date: Faker::Date.backward(days: 14).to_s,
      service: Faker::Number.decimal(l_digits: 4),
      other_charge: Faker::Number.decimal(l_digits: 4),
      current_arrears_agreement_status: Faker::Lorem.characters(number: 3),
      current_balance: {
        value: Faker::Number.decimal(l_digits: 2),
        currency_code: Faker::Currency.code
      },
      primary_contact_name: Faker::Name.first_name,
      primary_contact_long_address: Faker::Address.street_address,
      primary_contact_postcode: Faker::Lorem.word
    },
    latest_action_diary_events: Array.new(5) { action_diary_event },
    latest_arrears_agreements: Array.new(5) { arrears_agreement }
  }.deep_merge(options)
end
