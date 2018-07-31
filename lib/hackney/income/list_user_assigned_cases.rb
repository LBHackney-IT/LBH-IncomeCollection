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
            Hackney::Income::Domain::TenancyListItem.new.tap do |t|
              t.primary_contact_name = tenancy.fetch(:primary_contact_name)
              t.primary_contact_short_address = tenancy.fetch(:primary_contact_short_address)
              t.primary_contact_postcode = tenancy.fetch(:primary_contact_postcode)
              t.current_balance = tenancy.fetch(:current_balance)
              t.ref = tenancy.fetch(:ref)
              t.current_arrears_agreement_status = tenancy.fetch(:current_arrears_agreement_status)
              t.latest_action_date = tenancy.fetch(:latest_action_date)
              t.latest_action_code = tenancy.fetch(:latest_action_code)
            end
          end
      end
    end
  end
end
