module Hackney
  module Income
    class ListUserAssignedCases
      def initialize(tenancy_assignment_gateway:, tenancy_gateway:)
        @tenancy_assignment_gateway = tenancy_assignment_gateway
        @tenancy_gateway = tenancy_gateway
      end

      def execute(user_id:)
        tenancies = @tenancy_assignment_gateway.assigned_tenancies(assignee_id: user_id)
        tenancy_refs = tenancies.map { |t| t.fetch(:ref) }

        @tenancy_gateway.get_tenancies(tenancy_refs)
      end
    end
  end
end
