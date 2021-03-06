module Hackney
  module Income
    class StubIncomeApiUsersGateway
      def initialize(api_host:, api_key:)
        @id = 0
      end

      def find_or_create_user(provider_uid:, provider:, name:, email:, first_name:, last_name:, provider_permissions:)
        {
          id: Hackney::Income::StubIncomeApiUsersGateway.generate_id(provider_uid: provider_uid, name: name), # create a number based off input
          name: name,
          email: email,
          first_name: first_name,
          last_name: last_name,
          provider_permissions: provider_permissions
        }
      end

      def self.generate_id(provider_uid:, name:)
        (provider_uid.to_s + name).to_i(36)
      end
    end
  end
end
