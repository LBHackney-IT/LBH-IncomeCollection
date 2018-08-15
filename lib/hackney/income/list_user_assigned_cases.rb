module Hackney
  module Income
    class ListUserAssignedCases
      def initialize(tenancy_case_gateway:)
        @tenancy_case_gateway = tenancy_case_gateway
      end

      def execute(assignee_id:)
        @tenancy_case_gateway.temp_case_list
      end
    end
  end
end
