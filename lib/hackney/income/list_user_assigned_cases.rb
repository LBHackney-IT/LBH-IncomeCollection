module Hackney
  module Income
    class ListUserAssignedCases
      def initialize(tenancy_case_gateway:)
        @tenancy_case_gateway = tenancy_case_gateway
      end

      def execute(assignee_id:)
        @tenancy_case_gateway
          .assigned_tenancies(assignee_id: assignee_id)
          .map do |tenancy|
            Hackney::TenancyListItem.new.tap do |t|
              t.address_1 = tenancy.fetch(:address_1)
              t.post_code = tenancy.fetch(:post_code)
              t.current_balance = tenancy.fetch(:current_balance)
              t.tenancy_ref = tenancy.fetch(:tenancy_ref)
              t.primary_contact = {
                first_name: tenancy.fetch(:first_name),
                last_name: tenancy.fetch(:last_name),
                title: tenancy.fetch(:title)
              }
            end
          end
      end
    end
  end
end
