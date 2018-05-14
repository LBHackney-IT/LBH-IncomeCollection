module Hackney
  module Income
    class ListTenanciesInArrears
      def initialize(tenancy_gateway:)
        @tenancy_gateway = tenancy_gateway
      end

      def execute
        @tenancy_gateway.get_tenancies_in_arrears.map do |tenancy|
          Hackney::TenancyListItem.new.tap do |item|
            item.address_1 = tenancy.fetch(:address_1)
            item.tenancy_ref = tenancy.fetch(:tenancy_ref)
            item.current_balance = tenancy.fetch(:current_balance)
            item.primary_contact = {
              first_name: tenancy.dig(:primary_contact, :first_name),
              last_name: tenancy.dig(:primary_contact, :last_name),
              title: tenancy.dig(:primary_contact, :title)
            }
          end
        end
      end
    end
  end
end
