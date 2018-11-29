module Hackney
  module Income
    class UpdateTenancy
      def initialize(tenancy_gateway:)
        @tenancy_gateway = tenancy_gateway
      end

      def execute(user_id:, tenancy_ref:, is_paused_until_date:, pause_reason:, pause_comment:, action_code:)
        @tenancy_gateway.update_tenancy(
          tenancy_ref: tenancy_ref, 
          is_paused_until_date: is_paused_until_date,
          user_id: user_id,
          pause_reason: pause_reason,
          pause_comment: pause_comment,
          action_code: action_code
          )
      end
    end
  end
end
