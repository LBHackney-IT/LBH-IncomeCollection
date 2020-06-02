require 'rails_helper'

describe Hackney::Income::ViewActions do
  let!(:tenancy_ref) { Faker::Lorem.characters(number: 8) }
  let!(:actions) do
    [
      Hackney::Income::Domain::ActionDiaryEntry.new.tap do |t|
        t.balance = Faker::Number.decimal(l_digits: 2)
        t.code = Faker::Lorem.characters(number: 3)
        t.type = Faker::Lorem.characters(number: 3)
        t.date = Faker::Date.forward(days: 100).to_s
        t.comment = Faker::Lorem.words(number: 10)
        t.universal_housing_username = Faker::Lorem.words(number: 2)
      end,
      Hackney::Income::Domain::ActionDiaryEntry.new.tap do |t|
        t.balance = Faker::Number.decimal(l_digits: 2)
        t.code = Faker::Lorem.characters(number: 3)
        t.type = Faker::Lorem.characters(number: 3)
        t.date = Faker::Date.forward(days: 100).to_s
        t.comment = Faker::Lorem.words(number: 10)
        t.universal_housing_username = Faker::Lorem.words(number: 2)
      end
    ]
  end
  let!(:actions_hash) do
    [
      {
        balance: actions[0].balance,
        code: actions[0].code,
        type: actions[0].type,
        date: actions[0].date,
        display_date: actions[0].display_date,
        comment: actions[0].comment,
        universal_housing_username: actions[0].universal_housing_username
      },
      {
        balance: actions[1].balance,
        code: actions[1].code,
        type: actions[1].type,
        date: actions[1].date,
        display_date: actions[1].display_date,
        comment: actions[1].comment,
        universal_housing_username: actions[1].universal_housing_username
      }
    ]
  end
  let!(:gateway_double) { double('Actions Gateway', get_actions_for: actions) }

  subject { described_class.new(get_diary_entries_gateway: gateway_double) }

  context 'when viewing actions for a tenancy' do
    it 'should retrieve all actions for a given tenancy' do
      expect(gateway_double).to receive(:get_actions_for).once.with(tenancy_ref: tenancy_ref)
      expect(subject.execute(tenancy_ref: tenancy_ref)).to eq(actions_hash)
    end
  end
end
