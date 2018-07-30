module Hackney
  module Income
    class ListTenanciesInArrears
      def initialize(tenancy_gateway:)
        @tenancy_gateway = tenancy_gateway
      end

      def execute
        @tenancy_gateway.get_tenancies_in_arrears
      end
    end
  end
end
