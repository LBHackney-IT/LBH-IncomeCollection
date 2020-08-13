require 'rails_helper'

describe Hackney::Income::UpdateCourtCase do
  let(:court_case_gateway) { instance_double(Hackney::Income::CourtCasesGateway) }
  let(:court_case_params) do
    {
      id: Faker::Lorem.characters(number: 6),
      court_date: Faker::Date.between(from: 5.days.ago, to: Date.today),
      court_outcome: nil,
      balance_on_court_outcome_date: nil,
      strike_out_date: nil,
      terms: nil,
      disrepair_counter_claim: nil
    }
  end

  subject { described_class.new(court_cases_gateway: court_case_gateway) }

  it 'should pass the required data through to the gateway' do
    expect(court_case_gateway).to receive(:update_court_case).with(court_case_params: court_case_params)
    subject.execute(court_case_params: court_case_params)
  end
end
