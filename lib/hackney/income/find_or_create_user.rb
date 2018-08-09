module Hackney
  module Income
    class FindOrCreateUser
      def initialize(users_gateway:)
        @users_gateway = users_gateway
      end

      def execute(provider_uid:, provider:, name:, email:, first_name:, last_name:, provider_permissions:)
        @users_gateway.find_or_create_user(
          provider_uid: provider_uid,
          provider: provider,
          name: name,
          email: email,
          first_name: first_name,
          last_name: last_name,
          provider_permissions: provider_permissions
        )
      end
    end
  end
end
