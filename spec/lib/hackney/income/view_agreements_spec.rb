require 'rails_helper'

describe Hackney::Income::ViewAgreements do
  let!(:tenancy_ref) { Faker::Lorem.characters(number: 8) }
  let!(:agreements) do
    [
      Hackney::Income::Domain::Agreement.new.tap do |t|
        t.tenancy_ref = tenancy_ref
        t.agreement_type = 'informal'
        t.starting_balance = Faker::Commerce.price(range: 10...1000)
        t.amount = Faker::Commerce.price(range: 10...100)
        t.start_date = Faker::Date.between(from: 10.days.ago, to: Date.today).to_s,
                       t.frequency = %w[weekly monthly].sample,
                       t.current_state = 'live'
      end,
      Hackney::Income::Domain::Agreement.new.tap do |t|
        t.tenancy_ref = tenancy_ref
        t.agreement_type = 'informal'
        t.starting_balance = Faker::Commerce.price(range: 10...1000)
        t.amount = Faker::Commerce.price(range: 10...100)
        t.start_date = Faker::Date.between(from: 15.days.ago, to: 11.days.ago).to_s,
                       t.frequency = %w[weekly monthly].sample,
                       t.current_state = 'breached'
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
