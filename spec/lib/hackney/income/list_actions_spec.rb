require 'rails_helper'

describe Hackney::Income::ListActions do
  let(:actions_gateway) { instance_double(Hackney::Income::ActionsGateway) }
  let(:tenancies) { [] }

  let(:paused) { Faker::Boolean.boolean }
  let(:full_patch) { Faker::Boolean.boolean }
  let(:patch) { Faker::Lorem.characters(number: 3) }
  let(:page_number) { Faker::Number.number(digits: 2).to_i }
  let(:number_per_page) { Faker::Number.number(digits: 2).to_i }
  let(:number_of_pages) { (tenancies.count.to_f / number_per_page).ceil }

  let(:list_cases) { described_class.new(actions_gateway: actions_gateway) }

  let(:filter_params) do
    Hackney::Income::FilterParams::ListCasesParams.new(
      page: page_number, count_per_page: number_per_page, paused: paused,
      full_patch: full_patch, patch: patch
    )
  end

  subject { list_cases.execute(filter_params: filter_params, service_area_type: :leasehold) }

  let(:actions) { (0..Faker::Number.between(from: 1, to: 10)).to_a.map { generate_action } }

  before do
    expected_args = { filter_params: filter_params }
    expect(actions_gateway).to receive(:get_actions).with(expected_args).and_return(
      actions: actions,
      number_of_pages: number_of_pages
    )
  end

  it 'should return expected params' do
    expect(subject.actions.count).to eq(actions.count)
    expect(subject).to have_attributes(
      paused: paused,
      page_number: page_number,
      number_of_pages: number_of_pages
    )
  end

  it 'should return Hackney::Income::Domain::LeaseholdActionListItem objects' do
    expect(subject.actions).to all(be_kind_of(Hackney::Income::Domain::LeaseholdActionListItem))
  end

  it 'only returns one case' do
    expect(subject.actions.count).to eq(actions.count)
  end

  def generate_action
    {
        tenancy_ref: "#{Faker::Number.number(digits: 6)}/#{Faker::Number.number(digits: 2)}",
        balance: Faker::Number.decimal(l_digits: 3, r_digits: 3),
        payment_ref: Faker::Number.number(digits: 10).to_s,
        patch_code: Faker::Alphanumeric.alpha(number: 3).upcase,
        action_type: Faker::Music::RockBand.name,
        service_area_type: :leasehold,
        metadata: {
            property_address: "#{Faker::Address.street_address}, London, #{Faker::Address.postcode}",
            lessee: Faker::Name.name,
            tenure_type: Faker::Music::RockBand.name,
            direct_debit_status: ['Live', 'First Payment', 'Cancelled', 'Last Payment'].sample,
            latest_letter: Faker::Alphanumeric.alpha(number: 3).upcase,
            latest_letter_date: Faker::Date.between(from: 20.days.ago, to: Date.today).to_s
        }
    }
  end
end
