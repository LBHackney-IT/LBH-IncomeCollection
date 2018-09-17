module Hackney
  module Income
    class StubRegisterUsersGateway
      def initialize(api_host:, api_key:)
        @id = 0
      end

      def find_or_create_user(provider_uid:, provider:, name:, email:, first_name:, last_name:, provider_permissions:)
        {
          id: @id += 1,
          name: name,
          email: email,
          first_name: first_name,
          last_name: last_name,
          provider_permissions: provider_permissions
        }
      end
    end
  end
end
