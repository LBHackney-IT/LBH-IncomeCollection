module Hackney
  module Income
    class ViewActions
      def initialize(actions_gateway:)
        @actions_gateway = actions_gateway
      end

      def execute(tenancy_ref:)
        @actions_gateway.get_actions_for(tenancy_ref: tenancy_ref)
      end
    end
  end
end
