require 'rails_helper'

describe Hackney::Income::ViewActions do
  let!(:tenancy_ref) { Faker::Lorem.characters(8) }
  let!(:actions) do
    [
      Hackney::Income::Domain::ActionDiaryEntry.new.tap do |t|
        t.balance = Faker::Number.decimal(2)
        t.code = Faker::Lorem.characters(3)
        t.type = Faker::Lorem.characters(3)
        t.date = Faker::Date.forward(100)
        t.comment = Faker::Lorem.words(10)
        t.universal_housing_username = Faker::Lorem.words(2)
      end,
      Hackney::Income::Domain::ActionDiaryEntry.new.tap do |t|
        t.balance = Faker::Number.decimal(2)
        t.code = Faker::Lorem.characters(3)
        t.type = Faker::Lorem.characters(3)
        t.date = Faker::Date.forward(100)
        t.comment = Faker::Lorem.words(10)
        t.universal_housing_username = Faker::Lorem.words(2)
      end
    ]
  end
  let!(:gateway_double) { double('Actions Gateway', get_actions_for: actions) }

  subject { described_class.new(actions_gateway: gateway_double) }

  context 'when viewing actions for a tenancy' do
    it 'should retrieve all actions for a given tenancy' do
      expect(gateway_double).to receive(:get_actions_for).once.with(tenancy_ref: tenancy_ref)
      expect(subject.execute(tenancy_ref: tenancy_ref)).to eq(actions)
    end
  end
end
