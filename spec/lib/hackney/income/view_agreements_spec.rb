require 'rails_helper'

describe Hackney::Income::ViewAgreements do
  let!(:tenancy_ref) { Faker::Lorem.characters(number: 8) }
  let!(:agreements) do
    [
      Hackney::Income::Domain::Agreement.new.tap do |a|
        a.tenancy_ref = tenancy_ref
        a.agreement_type = 'informal'
        a.starting_balance = Faker::Commerce.price(range: 10...1000)
        a.amount = Faker::Commerce.price(range: 10...100)
        a.start_date = Faker::Date.between(from: 10.days.ago, to: Date.today).to_s
        a.frequency = %w[weekly monthly].sample
        a.current_state = 'live'
        a.created_at = Faker::Date.between(from: 6.days.ago, to: 3.days.ago).to_s
        a.created_by = Faker::Number.number(digits: 8)
        a.history = [
          Hackney::Income::Domain::AgreementState.new.tap do |s|
            s.date = Faker::Date.between(from: 2.days.ago, to: Date.today).to_s
            s.state = 'live'
          end
        ]
      end,
      Hackney::Income::Domain::Agreement.new.tap do |a|
        a.tenancy_ref = tenancy_ref
        a.agreement_type = 'informal'
        a.starting_balance = Faker::Commerce.price(range: 10...1000)
        a.amount = Faker::Commerce.price(range: 10...100)
        a.start_date = Faker::Date.between(from: 15.days.ago, to: 11.days.ago).to_s
        a.frequency = %w[weekly monthly].sample
        a.current_state = 'breached'
        a.created_at = Faker::Date.between(from: 6.days.ago, to: 3.days.ago).to_s
        a.created_by = Faker::Number.number(digits: 8)
        a.history = [
          Hackney::Income::Domain::AgreementState.new.tap do |s|
            s.date = Faker::Date.between(from: 1.day.ago, to: Date.today).to_s
            s.state = 'breached'
          end,
          Hackney::Income::Domain::AgreementState.new.tap do |s|
            s.date = Faker::Date.between(from: 10.days.ago, to: 2.days.ago).to_s
            s.state = 'live'
          end
        ]
      end
    ]
  end
  let!(:view_agreements_gateway) { double('Agreements Gateway', view_agreements: agreements) }

  subject { described_class.new(agreement_gateway: view_agreements_gateway) }

  context 'when viewing agreements for a tenancy' do
    it 'should retrieve all agreements for a given tenancy' do
      expect(view_agreements_gateway).to receive(:view_agreements).once.with(tenancy_ref: tenancy_ref)
      expect(subject.execute(tenancy_ref: tenancy_ref)).to eq(agreements)
    end
  end
end
