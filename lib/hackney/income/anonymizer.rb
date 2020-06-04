module Hackney
  module Income
    module Anonymizer
      module_function

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

      def anonymize_contacts(contacts:)
        contacts.each do |contact|
          title = Faker::Name.prefix
          first_name = Faker::Name.unique.first_name
          last_name = Faker::Name.unique.last_name
          post_code = "E#{Faker::Number.number(digits: 1)} #{Faker::Number.number(digits: 1)}#{Faker::Address.country_code}"
          contact.title = title if contact.title.present?
          contact.first_name = first_name if contact.first_name.present?
          contact.last_name = last_name if contact.last_name.present?
          contact.full_name = "#{first_name} #{last_name}" if contact.full_name.present?
          contact.email_address = Faker::Internet.email(name: "#{first_name} #{last_name}") if contact.email_address.present?
          contact.address_line_1 = Faker::Address.unique.street_address if contact.address_line_1.present?
          contact.address_line_2 = '' if contact.address_line_2.present?
          contact.address_line_3 = '' if contact.address_line_3.present?
          contact.telephone_1 = "07#{Faker::Number.leading_zero_number(digits: 9)}" if contact.telephone_1.present?
          contact.telephone_2 = "07#{Faker::Number.leading_zero_number(digits: 9)}" if contact.telephone_2.present?
          contact.telephone_3 = "07#{Faker::Number.leading_zero_number(digits: 9)}" if contact.telephone_3.present?
          contact.post_code = post_code if contact.post_code.present?
          contact.date_of_birth = Faker::Date.between(from: 60.years.ago, to: 20.years.ago) if contact.date_of_birth.present?
        end
      end

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
    end
  end
end
