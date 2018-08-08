module Hackney
  module Income
    class FindOrCreateUser
      def initialize(users_gateway:)
        @users_gateway = users_gateway
      end

      def execute(provider_uid:, provider:, name:, email:, first_name:, last_name:, ad_groups:)
        @users_gateway.find_or_create_user(
          provider_uid: provider_uid,
          provider: provider,
          name: name,
          email: email,
          first_name: first_name,
          last_name: last_name,
          ad_groups: ad_groups
        )
      end
    end
  end
end
