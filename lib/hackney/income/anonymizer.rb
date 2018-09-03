module Hackney
  module Income
    module Anonymizer
      def anonymize_tenancy(tenancy:)
        begin
          Faker::Config.random = Random.new(tenancy.ref.to_i)

          tenancy.primary_contact_name = [Faker::Name.prefix, Faker::Name.unique.first_name, Faker::Name.unique.last_name].join(' ')
          tenancy.primary_contact_long_address = Faker::Address.unique.street_address
          tenancy.primary_contact_postcode = Faker::Address.unique.zip

          Faker::Config.random = nil
        rescue Faker::UniqueGenerator::RetryLimitExceeded
          reset_unique_generator
        end

        tenancy
      end

      def anonymize_tenancy_list_item(tenancy:)
        begin
          Faker::Config.random = Random.new(tenancy.ref.to_i)

          tenancy.primary_contact_name = [Faker::Name.prefix, Faker::Name.unique.first_name, Faker::Name.unique.last_name].join(' ')
          tenancy.primary_contact_short_address = Faker::Address.unique.street_address
          tenancy.primary_contact_postcode = Faker::Address.unique.zip

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
