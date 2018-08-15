require 'rails_helper'

describe Hackney::Income::ListUserAssignedCases do
  let(:list_cases) { described_class.new(tenancy_case_gateway: tenancy_case_gateway) }
  let(:tenancy_case_gateway) { Hackney::Income::StubTenancyCaseGatewayBuilder.build_stub(cases: {}).new }

  subject { list_cases.execute(assignee_id: assignee_id) }

  context 'when retrieving cases for a user who has none assigned' do
    let(:assignee_id) { nil }

    it 'should return an empty list' do
      expect(subject).to eq([])
    end
  end

  context 'when retrieving cases for a user who has one assigned' do
    let(:assignee_id) { 1 }
    let(:cases_attributes) { [generate_tenancy] }

    before do
      tenancy_case_gateway.assign_user_case(
        assignee_id: assignee_id,
        case_attributes: cases_attributes.first
      )
    end

    it 'should return Hackney::Income::Domain::TenancyListItem objects' do
      expect(subject).to all(be_kind_of(Hackney::Income::Domain::TenancyListItem))
    end

    it 'should only return their assigned case' do
      expect(subject.count).to eq(1)
    end

    it 'should return their assigned case' do
      expect_tenancy_with_attributes(cases_attributes.first)
    end
  end

  context 'when retrieving cases for a user who has multiple assigned' do
    let(:assignee_id) { 1 }
    let(:cases_attributes) { (0..Faker::Number.between(1, 10)).to_a.map { generate_tenancy } }

    before do
      cases_attributes.each do |attributes|
        tenancy_case_gateway.assign_user_case(
          assignee_id: assignee_id,
          case_attributes: attributes
        )
      end
    end

    it 'should return all their assigned cases' do
      cases_attributes.each do |attributes|
        expect_tenancy_with_attributes(attributes)
      end
    end
  end

  context 'when multiple users have assigned cases' do
    let(:assignee_id) { 1 }
    let(:other_assignee_id) { 2 }
    let(:user_case_attributes) { generate_tenancy }
    let(:other_user_case_attributes) { generate_tenancy }

    before do
      tenancy_case_gateway.assign_user_case(assignee_id: assignee_id, case_attributes: user_case_attributes)
      tenancy_case_gateway.assign_user_case(assignee_id: other_assignee_id, case_attributes: other_user_case_attributes)
    end

    it 'should return the assigned case for the correct user' do
      expect_tenancy_with_attributes(user_case_attributes)
    end

    it 'should NOT return the assigned case for the other user' do
      expect(subject.count).to eq(1)
    end
  end

  def generate_tenancy
    {
      ref: Faker::IDNumber.valid,
      current_balance: Faker::Number.decimal(2),
      current_arrears_agreement_status: Faker::Lorem.characters(3),
      latest_action_code: Faker::Lorem.characters(3),
      latest_action_date: Faker::Date.forward(100),
      primary_contact_name: [Faker::Name.prefix, Faker::Name.first_name, Faker::Name.last_name].join(' '),
      primary_contact_short_address: Faker::Address.street_address,
      primary_contact_postcode: Faker::Address.postcode,
      score: Faker::Number.number(3),
      band: Faker::Lorem.characters(5)
    }
  end

  def expect_tenancy_with_attributes(attributes)
    expect(subject).to include(
      an_object_having_attributes(
        current_balance: attributes.fetch(:current_balance),
        current_arrears_agreement_status: attributes.fetch(:current_arrears_agreement_status),
        ref: attributes.fetch(:ref),
        primary_contact_name: attributes.fetch(:primary_contact_name),
        primary_contact_postcode: attributes.fetch(:primary_contact_postcode),
        primary_contact_short_address: attributes.fetch(:primary_contact_short_address),
        latest_action_code: attributes.fetch(:latest_action_code),
        latest_action_date: attributes.fetch(:latest_action_date),
        score: attributes.fetch(:score),
        band: attributes.fetch(:band)
      )
    )
  end
end
