require 'rails_helper'
require 'date'

describe Hackney::Income::ViewTenancy do
  context 'when viewing a tenancy' do
    let!(:tenancy_gateway) { Hackney::Income::StubTenancyGatewayBuilder.build_stub.new }
    let!(:transactions_gateway) { Hackney::Income::StubTransactionsGateway.new }
    let!(:actions_gateway) { Hackney::Income::StubGetActionDiaryEntriesGateway.new }

    let(:timeline_dummy) { double }

    let!(:view_tenancy_use_case) do
      described_class.new(
        tenancy_gateway: tenancy_gateway,
        transactions_gateway: transactions_gateway,
        case_priority_gateway: tenancy_gateway,
        get_diary_entries_gateway: actions_gateway
      )
    end

    subject do
      view_tenancy_use_case.execute(tenancy_ref: tenancy_ref)
    end

    before do
      allow(Hackney::Income::Timeline).to receive(:build).and_return(timeline_dummy)
    end

    context 'with a tenancy_ref of 3456789' do
      let!(:tenancy_ref) { '3456789' }

      it 'should contain basic details about the tenancy' do
        expect(subject.ref).to eq('3456789')
        expect(subject.current_balance).to eq(1200.2)
      end

      it 'should contain case priority details' do
        expect(subject.case_priority.fetch('assigned_user')).to eq(
          'id' => 123,
          'name' => 'Billy Bob',
          'email' => 'Billy.Bob@hackney.gov.uk',
          'first_name' => 'Billy',
          'last_name' => 'Bob',
          'role' => 'credit_controller'
        )
      end

      it 'should contain the priority_band result' do
        expect(subject.case_priority.fetch('priority_band')).to eq('red')
      end

      it 'should contain NoSP served and expiry dates' do
        expect(subject.case_priority.fetch('nosp_served_date')).to eq('2016-08-17T00:00:00.000Z')
        expect(subject.case_priority.fetch('nosp_expiry_date')).to eq('2017-09-18T00:00:00.000Z')
      end

      it 'should contain the number of bedrooms of a property' do
        expect(subject.case_priority.fetch('num_bedrooms')).to eq(3)
      end

      it 'should include contact details' do
        expect(subject.primary_contact_name).to eq('Ms Diana Prince')
        expect(subject.primary_contact_long_address).to eq('1 Themyscira')
        expect(subject.primary_contact_postcode).to eq('E1 123')
      end

      it 'should contain detailed contact details from the CRM' do
        expect(subject.contacts.count).to be(1)
        expect(subject.contacts[0].fetch(:contact_id)).to eq('123456')
        expect(subject.contacts[0].fetch(:email_address)).to eq('test.email@email.server.com')
        expect(subject.contacts[0].fetch(:uprn)).to eq('0')
        expect(subject.contacts[0].fetch(:address_line_1)).to eq('123')
        expect(subject.contacts[0].fetch(:address_line_2)).to eq('Test Road')
        expect(subject.contacts[0].fetch(:address_line_3)).to eq('Delivery City')
        expect(subject.contacts[0].fetch(:first_name)).to eq('Rich')
        expect(subject.contacts[0].fetch(:last_name)).to eq('Foster')
        expect(subject.contacts[0].fetch(:full_name)).to eq('Richard Foster')
        expect(subject.contacts[0].fetch(:larn)).to eq('0')
        expect(subject.contacts[0].fetch(:telephone_1)).to eq('0101 1234')
        expect(subject.contacts[0].fetch(:telephone_2)).to eq('077777777')
        expect(subject.contacts[0].fetch(:telephone_3)).to eq(nil)
        expect(subject.contacts[0].fetch(:cautionary_alert)).to eq(false)
        expect(subject.contacts[0].fetch(:property_cautionary_alert)).to eq(false)
        expect(subject.contacts[0].fetch(:house_ref)).to eq('98765')
        expect(subject.contacts[0].fetch(:title)).to eq('Mr.')
        expect(subject.contacts[0].fetch(:full_address_display)).to eq('123 Test Road, Delivery City')
        expect(subject.contacts[0].fetch(:full_address_search)).to eq('Search')
        expect(subject.contacts[0].fetch(:post_code)).to eq('E0 123')
        expect(subject.contacts[0].fetch(:date_of_birth)).to eq('12th March, 1976')
        expect(subject.contacts[0].fetch(:hackney_homes_id)).to eq('1209')
        expect(subject.contacts[0].fetch(:responsible)).to eq(true)
      end

      it 'has a timeline object that has been built' do
        expect(subject.timeline).to eq(timeline_dummy)
      end

      it 'should contain agreements related to the tenancy' do
        expect(subject.agreements.count).to be(1)
        expect(subject.agreements[0]).to be_instance_of(Hackney::Income::Domain::ArrearsAgreement)

        expect(subject.agreements[0].amount).to eq('10.99')
        expect(subject.agreements[0].breached).to eq(false)
        expect(subject.agreements[0].clear_by).to eq('2018-11-01')
        expect(subject.agreements[0].frequency).to eq('weekly')
        expect(subject.agreements[0].start_balance).to eq('99.00')
        expect(subject.agreements[0].start_date).to eq('2018-01-01')
        expect(subject.agreements[0].status).to eq('active')
      end

      it 'should contain arrears actions against the tenancy' do
        expect(subject.arrears_actions.count).to be(1)
        expect(subject.arrears_actions[0].balance).to eq('100.00')
        expect(subject.arrears_actions[0].code).to eq('GEN')
        expect(subject.arrears_actions[0].type).to eq('general_note')
        expect(subject.arrears_actions[0].date).to eq('2018-01-01')
        expect(subject.arrears_actions[0].comment).to eq('this tenant is in arrears!!!')
        expect(subject.arrears_actions[0].universal_housing_username).to eq('Brainiac')
        expect(subject.arrears_actions[0].display_date).to eq('January 1st, 2018 00:00')
      end

      context 'when there have been no stored events on the tenancy' do
        it 'should only contain arrears actions' do
          expect(subject.arrears_actions.count).to eq(1)
        end
      end

      it 'should list all arrears actions by time descending' do
        times = subject.arrears_actions.map { |a| [a.date] }
        expect(times.sort.reverse).to eq(times)
      end
    end
  end
end
