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

      def sample_patch
        [
          '0114084/01',
          '029533/01',
          '0115514/01',
          '030793/01',
          '064966/01',
          '007472/01',
          '030793/01',
          '0102966/02',
          '046085/01',
          '050678/01',
          '0100984/01',
          '065919/01',
          '0900845/01',
          '091549/01',
          '022893/01',
          '0106280/01',
          '0100518/02',
          '0906592/01',
          '032494/01',
          '036679/01',
          '017526/01',
          '0113066/01',
          '016467/01',
          '040939/01',
          '066228/01',
          '0111614/01',
          '032494/01',
          '033405/01',
          '024667/01',
          '0900226/01'
        ]
      end
    end
  end
end
