module Hackney
  module Income
    class UpdateTenancy
      def initialize(tenancy_gateway:)
        @tenancy_gateway = tenancy_gateway
      end

      def execute(tenancy_ref:, is_paused_until:, pause_reason:, pause_comment:)
        @tenancy_gateway.update_tenancy(
          tenancy_ref: tenancy_ref,
          is_paused_until: is_paused_until,
          pause_reason: pause_reason,
          pause_comment: pause_comment
        )
      end
    end
  end
end
