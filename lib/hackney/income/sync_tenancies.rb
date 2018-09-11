module Hackney
  module Income
    class SyncTenancies
      def initialize(tenancy_source_gateway:, tenancy_persistence_gateway:)
        @tenancy_source_gateway = tenancy_source_gateway
        @tenancy_persistence_gateway = tenancy_persistence_gateway
      end

      def execute
        # tenancies = @tenancy_source_gateway.get_tenancies_in_arrears
        tenancies = tenancy_list_gateway.temp_case_list
        @tenancy_persistence_gateway.persist(tenancies: tenancies)

        tenancies.each do |t|
          @tenancy_persistence_gateway.assign_user(tenancy_ref: t.ref, user_id: 1)
        end

        tenancies.map(&:ref)
      end

      private

      def tenancy_list_gateway
        Hackney::Income::LessDangerousTenancyGateway.new(
          api_host: ENV['INCOME_COLLECTION_LIST_API_HOST'],
          api_key: ENV['INCOME_COLLECTION_API_KEY']
        )
      end
    end
  end
end
