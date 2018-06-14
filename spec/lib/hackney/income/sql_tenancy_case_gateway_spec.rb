require 'rails_helper'

describe Hackney::Income::SqlTenancyCaseGateway do
  subject { described_class.new }

  context 'when persisting tenancies which do not exist in the database' do
    let(:tenancy) do
      {
        address_1: Faker::Address.street_address,
        post_code: Faker::Address.postcode,
        tenancy_ref: Faker::Number.number(6),
        current_balance: Faker::Number.decimal(2),
        priority_band: Faker::Space.galaxy,
        primary_contact: {
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          title: Faker::Name.title
        }
      }
    end

    before do
      subject.persist(tenancy: tenancy)
    end

    it 'should save the tenancies in the database' do
      expect(Hackney::Models::Tenancy.find_by(ref: tenancy.fetch(:tenancy_ref))).to have_attributes(
        address_1: tenancy.fetch(:address_1),
        post_code: tenancy.fetch(:post_code),
        current_balance: tenancy.fetch(:current_balance),
        priority_band: tenancy.fetch(:priority_band),
        primary_contact_first_name: tenancy.dig(:primary_contact, :first_name),
        primary_contact_last_name: tenancy.dig(:primary_contact, :last_name),
        primary_contact_title: tenancy.dig(:primary_contact, :title)
      )
    end
  end

  context 'when persisting a tenancy which already exists in the database' do
    let(:tenancy) do
      {
        address_1: Faker::Address.street_address,
        post_code: Faker::Address.postcode,
        tenancy_ref: Faker::Number.number(6),
        current_balance: Faker::Number.decimal(2),
        priority_band: Faker::Space.galaxy,
        primary_contact: {
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          title: Faker::Name.title
        }
      }
    end

    let(:existing_tenancy_record) do
      Hackney::Models::Tenancy.create!(ref: tenancy.fetch(:tenancy_ref))
    end

    before do
      existing_tenancy_record
      subject.persist(tenancy: tenancy)
    end

    it 'should not create a new record' do
      expect(Hackney::Models::Tenancy.count).to eq(1)
    end

    it 'should update the existing record' do
      expect(existing_tenancy_record.reload).to have_attributes(
        address_1: tenancy.fetch(:address_1),
        post_code: tenancy.fetch(:post_code),
        current_balance: tenancy.fetch(:current_balance),
        priority_band: tenancy.fetch(:priority_band),
        primary_contact_first_name: tenancy.dig(:primary_contact, :first_name),
        primary_contact_last_name: tenancy.dig(:primary_contact, :last_name),
        primary_contact_title: tenancy.dig(:primary_contact, :title)
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
          tenancy_ref: tenancy.ref,
          address_1: tenancy.address_1,
          post_code: tenancy.post_code,
          current_balance: tenancy.current_balance,
          first_name: tenancy.primary_contact_first_name,
          last_name: tenancy.primary_contact_last_name,
          title: tenancy.primary_contact_title,
          priority_band: tenancy.priority_band
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
          tenancy_ref: user_tenancy.ref,
          address_1: user_tenancy.address_1,
          post_code: user_tenancy.post_code,
          current_balance: user_tenancy.current_balance,
          first_name: user_tenancy.primary_contact_first_name,
          last_name: user_tenancy.primary_contact_last_name,
          title: user_tenancy.primary_contact_title,
          priority_band: user_tenancy.priority_band
        }])
      end
    end
  end

  def create_tenancy
    Hackney::Models::Tenancy.create!(
      ref: Faker::Number.number(6),
      address_1: Faker::Address.street_address,
      post_code: Faker::Address.postcode,
      current_balance: Faker::Number.decimal(2),
      primary_contact_first_name: Faker::Name.first_name,
      primary_contact_last_name: Faker::Name.last_name,
      primary_contact_title: Faker::Name.title,
      priority_band: Faker::Space.galaxy
    )
  end
end
