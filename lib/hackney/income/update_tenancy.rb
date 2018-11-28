module Hackney
  module Income
    class UpdateTenancy
      def initialize(tenancy_gateway:)
        @tenancy_gateway = tenancy_gateway
      end

      def execute(user_id:, tenancy_ref:, is_paused_until:, pause_reason:, pause_comment:, action_code:)
        @tenancy_gateway.update_tenancy(
          user_id: user_id,
          tenancy_ref: tenancy_ref,
          is_paused_until: is_paused_until,
          pause_reason: pause_reason,
          pause_comment: pause_comment,
          action_code: action_code
        )
      end
    end
  end
end
