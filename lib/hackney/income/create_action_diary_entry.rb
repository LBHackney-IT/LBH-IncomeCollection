module Hackney
  module Income
    class CreateActionDiaryEntry
      def initialize(create_action_diary_gateway:)
        @action_diary_gateway = create_action_diary_gateway
      end

      def execute(username:, tenancy_ref:, action_code:, comment:)
        @action_diary_gateway.create_action_diary_entry(
          username: username,
          tenancy_ref: tenancy_ref,
          action_code: action_code,
          comment: comment
        )
      end
    end
  end
end
