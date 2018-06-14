module Hackney
  module Income
    class SyncTenancies
      def initialize(tenancy_source_gateway:, tenancy_persistence_gateway:, transactions_gateway:, users_gateway:)
        @tenancy_source_gateway = tenancy_source_gateway
        @tenancy_persistence_gateway = tenancy_persistence_gateway
        @transactions_gateway = transactions_gateway
        @users_gateway = users_gateway
      end

      def execute
        users = @users_gateway.all_users.cycle
        tenancies = @tenancy_source_gateway.get_tenancies_in_arrears

        persistable_tenancies = tenancies.map(&method(:persistable_tenancy))
        prioritised_tenancies = persistable_tenancies.sort_by { |t| t.fetch(:priority_band) }

        prioritised_tenancies.each do |attributes|
          @tenancy_persistence_gateway.persist(tenancy: attributes)
          next unless users.any?

          user_id = users.next.fetch(:id)
          @tenancy_persistence_gateway.assign_user(tenancy_ref: attributes.fetch(:tenancy_ref), user_id: user_id)
        end

        tenancies.map { |t| t.fetch(:tenancy_ref) }
      end

      private

      def persistable_tenancy(tenancy_list_item)
        tenancy = @tenancy_source_gateway.get_tenancy(tenancy_ref: tenancy_list_item.fetch(:tenancy_ref))
        transactions = @transactions_gateway.transactions_for(tenancy_ref: tenancy_list_item.fetch(:tenancy_ref))

        {
          address_1: tenancy_list_item.fetch(:address_1),
          current_balance: tenancy_list_item.fetch(:current_balance),
          post_code: tenancy_list_item.fetch(:post_code),
          tenancy_ref: tenancy_list_item.fetch(:tenancy_ref),
          priority_band: priority_band_for(tenancy, transactions),
          primary_contact: {
            first_name: tenancy_list_item.dig(:primary_contact, :first_name),
            last_name: tenancy_list_item.dig(:primary_contact, :last_name),
            title: tenancy_list_item.dig(:primary_contact, :title)
          }
        }
      end

      def priority_band_for(tenancy, transactions)
        TenancyPrioritiser.new(tenancy: tenancy, transactions: transactions).priority_band
      end
    end
  end
end
