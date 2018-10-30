module Hackney
  module Income
    class UpdateTenancy
      def initialize(tenancy_gateway:)
        @tenancy_gateway = tenancy_gateway
      end

      def execute(tenancy_ref:, is_paused_until:)
        @tenancy_gateway.update_tenancy(tenancy_ref: tenancy_ref, is_paused_until: is_paused_until)
      end
    end
  end
end
