require 'rails_helper'

describe Hackney::Income::SqlTenancyCaseGateway do
  subject { described_class.new }

  context 'when persisting tenancies which do not exist in the database' do
    let(:tenancies) do
      (0..Faker::Number.between(1, 10)).to_a.map do
        Hackney::Income::Domain::TenancyListItem.new.tap do |t|
          t.primary_contact_name = [Faker::Name.title, Faker::Name.first_name, Faker::Name.last_name].join(' ')
          t.primary_contact_short_address = Faker::Address.street_address
          t.primary_contact_postcode = Faker::Address.postcode
          t.ref = Faker::Number.number(6)
          t.current_balance = Faker::Number.decimal(2)
          t.latest_action_code = Faker::Number.number(3)
          t.current_arrears_agreement_status = Faker::Number.number(3)
          t.latest_action_date = Faker::Date.forward(100)
        end
      end
    end

    before do
      subject.persist(tenancies: tenancies)
    end

    it 'should save the tenancies in the database' do
      tenancies.each do |tenancy|
        expect(Hackney::Models::Tenancy.find_by(ref: tenancy.ref)).to have_attributes(
          primary_contact_short_address: tenancy.primary_contact_short_address,
          primary_contact_postcode: tenancy.primary_contact_postcode,
          current_balance: tenancy.current_balance,
          primary_contact_name: tenancy.primary_contact_name,
          latest_action_code: tenancy.latest_action_code,
          latest_action_date: tenancy.latest_action_date.strftime('%Y-%m-%d'),
          current_arrears_agreement_status: tenancy.current_arrears_agreement_status
        )
      end
    end
  end

  context 'when persisting a tenancy which already exists in the database' do
    let(:tenancy) do
      Hackney::Income::Domain::TenancyListItem.new.tap do |t|
        t.primary_contact_name = [Faker::Name.title, Faker::Name.first_name, Faker::Name.last_name].join(' ')
        t.primary_contact_short_address = Faker::Address.street_address
        t.primary_contact_postcode = Faker::Address.postcode
        t.ref = Faker::Number.number(6)
        t.current_balance = Faker::Number.decimal(2)
        t.latest_action_code = Faker::Number.number(3)
        t.current_arrears_agreement_status = Faker::Number.number(3)
        t.latest_action_date = Faker::Date.forward(100)
      end
    end

    let(:existing_tenancy_record) do
      Hackney::Models::Tenancy.create!(ref: tenancy.ref)
    end

    before do
      existing_tenancy_record
      subject.persist(tenancies: [tenancy])
    end

    it 'should not create a new record' do
      expect(Hackney::Models::Tenancy.count).to eq(1)
    end

    it 'should update the existing record' do
      expect(existing_tenancy_record.reload).to have_attributes(
        primary_contact_short_address: tenancy.primary_contact_short_address,
        primary_contact_postcode: tenancy.primary_contact_postcode,
        current_balance: tenancy.current_balance,
        primary_contact_name: tenancy.primary_contact_name,
        latest_action_code: tenancy.latest_action_code,
        latest_action_date: tenancy.latest_action_date.strftime('%Y-%m-%d'),
        current_arrears_agreement_status: tenancy.current_arrears_agreement_status
      )
    end
  end

  context 'when assigning a user to a case' do
    let!(:tenancy_ref) { Faker::Number.number(6) }
    let!(:tenancy) { Hackney::Models::Tenancy.create(ref: tenancy_ref) }
    let!(:user) { Hackney::Models::User.create }

    it 'should assign the user' do
      subject.assign_user(tenancy_ref: tenancy_ref, user_id: user.id)
      expect(tenancy.reload).to have_attributes(
        assigned_user: user
      )
    end
  end

  context 'when retrieving cases assigned to a user' do
    let(:assignee_id) { 1 }
    let(:assigned_tenancies) { subject.assigned_tenancies(assignee_id: assignee_id) }

    context 'and the user has no assigned cases' do
      it 'should return no cases' do
        expect(assigned_tenancies).to be_empty
      end
    end

    context 'and the user has one assigned case' do
      let(:tenancy) { create_tenancy }
      before { subject.assign_user(tenancy_ref: tenancy.ref, user_id: assignee_id) }

      it 'should return the user\'s case' do
        expect(assigned_tenancies).to include(
          ref: tenancy.ref,
          primary_contact_short_address: tenancy.primary_contact_short_address,
          primary_contact_postcode: tenancy.primary_contact_postcode,
          current_balance: tenancy.current_balance,
          primary_contact_name: tenancy.primary_contact_name,
          latest_action_code: tenancy.latest_action_code,
          latest_action_date: tenancy.latest_action_date,
          current_arrears_agreement_status: tenancy.current_arrears_agreement_status
        )
      end
    end

    context 'and many users have assigned cases' do
      let(:user_tenancy) { create_tenancy }
      let(:other_assignee_id) { 1234 }

      before do
        subject.assign_user(tenancy_ref: user_tenancy.ref, user_id: assignee_id)
        subject.assign_user(tenancy_ref: create_tenancy.ref, user_id: other_assignee_id)
        subject.assign_user(tenancy_ref: create_tenancy.ref, user_id: other_assignee_id)
      end

      it 'should only return the user\'s cases' do
        expect(assigned_tenancies).to eq([{
          ref: user_tenancy.ref,
          primary_contact_short_address: user_tenancy.primary_contact_short_address,
          primary_contact_postcode: user_tenancy.primary_contact_postcode,
          current_balance: user_tenancy.current_balance,
          primary_contact_name: user_tenancy.primary_contact_name,
          latest_action_code: user_tenancy.latest_action_code,
          latest_action_date: user_tenancy.latest_action_date,
          current_arrears_agreement_status: user_tenancy.current_arrears_agreement_status
        }])
      end
    end
  end

  def create_tenancy
    t = Hackney::Income::Domain::TenancyListItem.new.tap do |t|
      t.primary_contact_name = [Faker::Name.title, Faker::Name.first_name, Faker::Name.last_name].join(' ')
      t.primary_contact_short_address = Faker::Address.street_address
      t.primary_contact_postcode = Faker::Address.postcode
      t.ref = Faker::Number.number(6)
      t.current_balance = Faker::Number.decimal(2)
      t.latest_action_code = Faker::Number.number(3)
      t.current_arrears_agreement_status = Faker::Number.number(3)
      t.latest_action_date = Faker::Date.forward(100)
    end

    Hackney::Models::Tenancy.create!(
      primary_contact_name: t.primary_contact_name,
      primary_contact_short_address: t.primary_contact_short_address,
      primary_contact_postcode: t.primary_contact_postcode,
      ref: t.ref,
      current_balance: t.current_balance,
      latest_action_code: t.latest_action_code,
      current_arrears_agreement_status: t.current_arrears_agreement_status,
      latest_action_date: t.latest_action_date
    )
  end
end
