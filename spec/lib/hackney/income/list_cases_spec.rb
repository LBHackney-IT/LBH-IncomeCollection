require 'rails_helper'

describe Hackney::Income::ListCases do
  let(:tenancy_gateway) { Hackney::Income::StubTenancyGatewayBuilder.build_stub(with_tenancies: tenancies).new }
  let(:tenancies) { [] }

  let(:paused) { Faker::Boolean.boolean }
  let(:full_patch) { Faker::Boolean.boolean }
  let(:upcoming_court_dates) { Faker::Boolean.boolean }
  let(:upcoming_evictions) { Faker::Boolean.boolean }

  let(:patch) { Faker::Lorem.characters(number: 3) }
  let(:page_number) { Faker::Number.number(digits: 2).to_i }
  let(:number_per_page) { Faker::Number.number(digits: 2).to_i }
  let(:number_of_pages) { (tenancies.count.to_f / number_per_page).ceil }

  let(:list_cases) { described_class.new(tenancy_gateway: tenancy_gateway) }

  let(:filter_params) do
    Hackney::Income::FilterParams::ListCasesParams.new(
      page: page_number, count_per_page: number_per_page, paused: paused,
      full_patch: full_patch, upcoming_court_dates: upcoming_court_dates,
      upcoming_evictions: upcoming_evictions, patch: patch
    )
  end

  subject { list_cases.execute(filter_params: filter_params) }

  it 'should query the tenancy gateway for cases for the given filters, on that page' do
    expected_args = { filter_params: filter_params }
    expect(tenancy_gateway).to receive(:get_tenancies).with(expected_args).and_call_original

    subject
  end

  context 'when retrieving cases when there is only one' do
    let(:case_attributes) { generate_tenancy }
    let(:tenancy_ref) { case_attributes.fetch(:tenancy_ref) }
    let(:tenancies) { [case_attributes] }

    it 'should return expected params' do
      expect(subject.tenancies.count).to eq(tenancies.count)
      expect(subject).to have_attributes(
        paused: paused,
        page_number: page_number,
        number_of_pages: number_of_pages
      )
    end

    it 'should return Hackney::Income::Domain::TenancyListItem objects' do
      expect(subject.tenancies).to all(be_kind_of(Hackney::Income::Domain::TenancyListItem))
    end

    it 'only returns one case' do
      expect(subject.tenancies.count).to eq(1)
    end

    it 'has the correct attributes' do
      expect_tenancy_with_attributes(case_attributes)
    end
  end

  context 'when retrieving multiple cases' do
    let(:tenancies) { (0..Faker::Number.between(from: 1, to: 10)).to_a.map { generate_tenancy } }

    it 'should return the cases' do
      tenancies.each do |attributes|
        expect_tenancy_with_attributes(attributes)
      end
    end
  end

  def generate_tenancy
    {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      title: Faker::Name.prefix,
      address_1: Faker::Address.street_address,
      tenancy_ref: Faker::IDNumber.valid,
      current_balance: Faker::Number.decimal(l_digits: 2),
      current_arrears_agreement_status: Faker::Lorem.characters(number: 3),
      latest_action_code: Faker::Lorem.characters(number: 3),
      latest_action_date: Faker::Date.forward(days: 100),
      postcode: Faker::Address.postcode,
      score: Faker::Number.number(digits: 3),
      band: Faker::Lorem.characters(number: 5)
    }
  end

  def expect_tenancy_with_attributes(attributes)
    expect(subject.tenancies).to include(
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
