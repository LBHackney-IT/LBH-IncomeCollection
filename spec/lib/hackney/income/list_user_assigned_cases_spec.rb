require 'rails_helper'

describe Hackney::Income::ListUserAssignedCases do
  let(:tenancy_gateway) { Hackney::Income::StubTenancyGatewayBuilder.build_stub(with_tenancies: tenancies).new }
  let(:tenancy_assignment_gateway) { Hackney::Income::StubTenancyCaseGatewayBuilder.build_stub.new }
  let(:tenancies) { [] }
  let(:user_id) { 1 }

  let(:list_cases) do
    described_class.new(
      tenancy_assignment_gateway: tenancy_assignment_gateway,
      tenancy_gateway: tenancy_gateway
    )
  end

  subject { list_cases.execute(user_id: user_id) }

  context 'when retrieving cases for a user who has none assigned' do
    let(:user_id) { 1000 }

    it 'should return an empty list' do
      expect(subject).to eq([])
    end
  end

  context 'when retrieving cases for a user who has one assigned' do
    let(:case_attributes) { generate_tenancy }
    let(:tenancy_ref) { case_attributes.fetch(:tenancy_ref) }
    let(:tenancies) { [case_attributes] }

    before do
      tenancy_assignment_gateway.assign_user(
        assignee_id: user_id,
        tenancy_ref: tenancy_ref
      )
    end

    it 'should return Hackney::Income::Domain::TenancyListItem objects' do
      expect(subject).to all(be_kind_of(Hackney::Income::Domain::TenancyListItem))
    end

    it 'should only return their assigned case' do
      expect(subject.count).to eq(1)
    end

    it 'should return attributes for their assigned case' do
      expect_tenancy_with_attributes(case_attributes)
    end
  end

  context 'when retrieving cases for a user who has multiple assigned' do
    let(:tenancies) { (0..Faker::Number.between(1, 10)).to_a.map { generate_tenancy } }

    before do
      tenancies.each do |attributes|
        tenancy_assignment_gateway.assign_user(
          assignee_id: user_id,
          tenancy_ref: attributes.fetch(:tenancy_ref)
        )
      end
    end

    it 'should return all their assigned cases' do
      tenancies.each do |attributes|
        expect_tenancy_with_attributes(attributes)
      end
    end
  end

  context 'when multiple users have assigned cases' do
    let(:other_user_id) { 2 }
    let(:user_tenancy) { generate_tenancy }
    let(:other_user_tenancy) { generate_tenancy }
    let(:tenancies) { [user_tenancy, other_user_tenancy] }

    before do
      tenancy_assignment_gateway.assign_user(assignee_id: user_id, tenancy_ref: user_tenancy.fetch(:tenancy_ref))
      tenancy_assignment_gateway.assign_user(assignee_id: other_user_id, tenancy_ref: other_user_tenancy.fetch(:tenancy_ref))
    end

    it 'should return the assigned case for the correct user' do
      expect_tenancy_with_attributes(user_tenancy)
    end

    it 'should NOT return the assigned case for the other user' do
      expect(subject.count).to eq(1)
    end
  end

  def generate_tenancy
    {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      title: Faker::Name.prefix,
      address_1: Faker::Address.street_address,
      tenancy_ref: Faker::IDNumber.valid,
      current_balance: Faker::Number.decimal(2),
      current_arrears_agreement_status: Faker::Lorem.characters(3),
      latest_action_code: Faker::Lorem.characters(3),
      latest_action_date: Faker::Date.forward(100),
      postcode: Faker::Address.postcode,
      score: Faker::Number.number(3),
      band: Faker::Lorem.characters(5)
    }
  end

  def expect_tenancy_with_attributes(attributes)
    expect(subject).to include(
      an_object_having_attributes(
        ref: attributes.fetch(:tenancy_ref),
        primary_contact_name: [attributes.fetch(:title), attributes.fetch(:first_name), attributes.fetch(:last_name)].join(' '),
        primary_contact_short_address: attributes.fetch(:address_1),
        current_balance: attributes.fetch(:current_balance),
        current_arrears_agreement_status: attributes.fetch(:current_arrears_agreement_status),
        primary_contact_postcode: attributes.fetch(:postcode),
        latest_action_code: attributes.fetch(:latest_action_code),
        latest_action_date: attributes.fetch(:latest_action_date),
        score: attributes.fetch(:score),
        band: attributes.fetch(:band)
      )
    )
  end
end
