require 'rails_helper'

describe Hackney::Income::SqlTenancyCaseGateway do
  subject { described_class.new }

  context 'when persisting tenancies which do not exist in the database' do
    let(:tenancies) do
      (0..Faker::Number.between(1, 10)).to_a.map do
        {
          address_1: Faker::Address.street_address,
          post_code: Faker::Address.postcode,
          tenancy_ref: Faker::Number.number(6),
          current_balance: Faker::Number.decimal(2),
          primary_contact: {
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            title: Faker::Name.title
          }
        }
      end
    end

    before do
      subject.persist(tenancies: tenancies)
    end

    it 'should save the tenancies in the database' do
      tenancies.each do |tenancy|
        expect(Hackney::Models::Tenancy.find_by(ref: tenancy.fetch(:tenancy_ref))).to have_attributes(
          address_1: tenancy.fetch(:address_1),
          post_code: tenancy.fetch(:post_code),
          current_balance: tenancy.fetch(:current_balance),
          primary_contact_first_name: tenancy.dig(:primary_contact, :first_name),
          primary_contact_last_name: tenancy.dig(:primary_contact, :last_name),
          primary_contact_title: tenancy.dig(:primary_contact, :title)
        )
      end
    end
  end

  context 'when persisting a tenancy which already exists in the database' do
    let(:tenancy) do
      {
        address_1: Faker::Address.street_address,
        post_code: Faker::Address.postcode,
        tenancy_ref: Faker::Number.number(6),
        current_balance: Faker::Number.decimal(2),
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
      subject.persist(tenancies: [tenancy])
    end

    it 'should not create a new record' do
      expect(Hackney::Models::Tenancy.count).to eq(1)
    end

    it 'should update the existing record' do
      expect(existing_tenancy_record.reload).to have_attributes(
        address_1: tenancy.fetch(:address_1),
        post_code: tenancy.fetch(:post_code),
        current_balance: tenancy.fetch(:current_balance),
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
end
