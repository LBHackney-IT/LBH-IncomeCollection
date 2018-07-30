module Hackney
  module Income
    class SyncTenancies
      def initialize(tenancy_source_gateway:, tenancy_persistence_gateway:)
        @tenancy_source_gateway = tenancy_source_gateway
        @tenancy_persistence_gateway = tenancy_persistence_gateway
      end

      def execute
        tenancies = @tenancy_source_gateway.get_tenancies_in_arrears
        @tenancy_persistence_gateway.persist(tenancies: tenancies)

        tenancies.map { |t| t.ref }
      end
    end
  end
end
