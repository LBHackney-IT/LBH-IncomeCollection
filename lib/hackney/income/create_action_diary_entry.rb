module Hackney
  module Income
    class CreateActionDiaryEntry
      def initialize(create_action_diary_gateway:)
        @action_diary_gateway = create_action_diary_gateway
      end

      def execute(user_id:, tenancy_ref:, action_code:, comment:)
        @action_diary_gateway.create_action_diary_entry(
          user_id: user_id,
          tenancy_ref: tenancy_ref,
          action_code: action_code,
          comment: comment
        )
      end
    end
  end
end
