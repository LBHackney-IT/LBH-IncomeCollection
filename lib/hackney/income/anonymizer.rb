module Hackney
  module Income
    module Anonymizer
      def anonymize_tenancy(tenancy:)
        with_tenancy_seeded(tenancy) do
          tenancy.primary_contact_name = [Faker::Name.prefix, Faker::Name.unique.first_name, Faker::Name.unique.last_name].join(' ')
          tenancy.primary_contact_long_address = Faker::Address.unique.street_address
          tenancy.primary_contact_postcode = Faker::Address.unique.zip
        end
      end

      def anonymize_tenancy_list_item(tenancy:)
        with_tenancy_seeded(tenancy) do
          tenancy.primary_contact_name = [Faker::Name.prefix, Faker::Name.unique.first_name, Faker::Name.unique.last_name].join(' ')
          tenancy.primary_contact_short_address = Faker::Address.unique.street_address
          tenancy.primary_contact_postcode = Faker::Address.unique.zip
        end
      end

      module_function :anonymize_tenancy
      module_function :anonymize_tenancy_list_item

      private

      def with_tenancy_seeded(tenancy, &block)
        begin
          Faker::UniqueGenerator.clear
          Faker::Config.random = tenancy_seed(tenancy)

          block.call
        rescue Faker::UniqueGenerator::RetryLimitExceeded
          Faker::UniqueGenerator.clear
        ensure
          Faker::Config.random = nil
        end

        tenancy
      end

      def tenancy_seed(tenancy)
        seed_int = tenancy.ref&.gsub('/', '')&.to_i
        Random.new(seed_int || 0)
      end

      module_function :with_tenancy_seeded
      module_function :tenancy_seed
    end
  end
end
