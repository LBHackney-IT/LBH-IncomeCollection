module Hackney
  module Income
    module Anonymizer
      def anonymize_tenancy(tenancy:)
        begin
          Faker::Config.random = Random.new(tenancy[:tenancy_ref].to_i)

          tenancy[:primary_contact].merge!(
            first_name: Faker::Name.unique.first_name,
            last_name: Faker::Name.unique.last_name,
            title: Faker::Name.prefix
          )

          tenancy[:address].merge!(
            address_1: Faker::Address.unique.street_address,
            post_code: 'H4C KN3Y'
          )

          Faker::Config.random = nil
        rescue Faker::UniqueGenerator::RetryLimitExceeded
          reset_unique_generator
        end

        tenancy
      end

      def anonymize_tenancy_list_item(tenancy:)
        begin
          Faker::Config.random = Random.new(tenancy[:tenancy_ref].to_i)

          tenancy[:primary_contact].merge!(
            first_name: Faker::Name.unique.first_name,
            last_name: Faker::Name.unique.last_name,
            title: Faker::Name.prefix
          )

          tenancy[:address_1] = Faker::Address.unique.street_address
          tenancy[:postcode] = Faker::Address.unique.zip

          Faker::Config.random = nil
        rescue Faker::UniqueGenerator::RetryLimitExceeded
          reset_unique_generator
        end

        tenancy
      end

      module_function :anonymize_tenancy
      module_function :anonymize_tenancy_list_item

      private

      def reset_unique_generator
        Faker::UniqueGenerator.clear
      end
    end
  end
end
