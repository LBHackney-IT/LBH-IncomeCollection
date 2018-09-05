module Hackney
  module Income
    class CreateActionDiaryEntry
      def initialize(action_diary_gateway:)
        @action_diary_gateway = action_diary_gateway
      end

      def execute(tenancy_ref:, balance:, code:, type:, date:, comment:, universal_housing_username:)
        @action_diary_gateway.create_action_diary_entry(
          tenancy_ref: tenancy_ref,
          balance: balance,
          code: code,
          type: type,
          date: date,
          comment: comment,
          universal_housing_username: universal_housing_username
        )
      end
    end
  end
end
