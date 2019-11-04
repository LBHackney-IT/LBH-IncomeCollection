module Hackney
  module Income
    class StubGetActionDiaryEntriesGateway
      def initialize(api_host: nil, api_key: nil); end

      def get_actions_for(tenancy_ref:)
        [
          Hackney::Income::Domain::ActionDiaryEntry.new.tap do |t|
            t.balance = Faker::Number.decimal(2)
            t.code = Faker::Lorem.characters(3)
            t.type = Faker::Lorem.characters(3)
            t.date = Faker::Date.forward(100).to_s
            t.comment = Faker::Lorem.words(10)
            t.universal_housing_username = Faker::Lorem.words(2)
          end,
          Hackney::Income::Domain::ActionDiaryEntry.new.tap do |t|
            t.balance = Faker::Number.decimal(2)
            t.code = Faker::Lorem.characters(3)
            t.type = Faker::Lorem.characters(3)
            t.date = Faker::Date.forward(100).to_s
            t.comment = Faker::Lorem.words(10)
            t.universal_housing_username = Faker::Lorem.words(2)
          end
        ]
      end
    end
  end
end
