require 'rails_helper'

describe Hackney::Income::CreateCourtCase do
  let(:create_court_case_gateway) { instance_double(Hackney::Income::CourtCasesGateway) }
  let(:create_court_case_params) do
    {
      tenancy_ref: Faker::Lorem.characters(number: 6),
      court_date: Faker::Date.between(from: 5.days.ago, to: Date.today),
      court_outcome: nil,
      balance_on_court_outcome_date: nil,
      strike_out_date: nil,
      terms: nil,
      disrepair_counter_claim: nil
    }
  end

  subject { described_class.new(court_cases_gateway: create_court_case_gateway) }

  it 'should pass the required data through to the gateway' do
    expect(create_court_case_gateway).to receive(:create_court_case).with(create_court_case_params: create_court_case_params)
    subject.execute(create_court_case_params: create_court_case_params)
  end
end
