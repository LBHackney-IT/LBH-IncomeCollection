require 'rails_helper'

describe Hackney::Income::ViewCourtCases do
  let!(:tenancy_ref) { "#{Faker::Lorem.characters(number: 6)}/#{Faker::Lorem.characters(number: 2)}" }

  let!(:court_cases) do
    [
      Hackney::Income::Domain::CourtCase.new.tap do |a|
        a.tenancy_ref = tenancy_ref
        a.court_date = Faker::Date.between(from: 5.days.ago, to: Date.today)
        a.court_outcome = nil
        a.balance_on_court_outcome_date = nil
        a.strike_out_date = nil
        a.terms = nil
        a.disrepair_counter_claim = nil
      end
    ]
  end
  let!(:view_court_cases_gateway) { double('Court Cases Gateway', view_court_cases: court_cases) }

  subject { described_class.new(court_cases_gateway: view_court_cases_gateway) }

  context 'when viewing court cases for a tenancy' do
    it 'should retrieve all court cases for a given tenancy' do
      expect(view_court_cases_gateway).to receive(:view_court_cases).once.with(tenancy_ref: tenancy_ref)
      expect(subject.execute(tenancy_ref: tenancy_ref)).to eq(court_cases)
    end
  end
end
