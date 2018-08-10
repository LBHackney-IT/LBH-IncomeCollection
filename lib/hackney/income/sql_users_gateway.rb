module Hackney
  module Income
    class SqlUsersGateway
      def find_or_create_user(provider_uid:, provider:, name:, email:, first_name:, last_name:, provider_permissions:)
        user = Hackney::Models::User.find_or_create_by!(provider_uid: provider_uid, provider: provider)
        user.update!(name: name, email: email, first_name: first_name, last_name: last_name, provider_permissions: provider_permissions)

        { id: user.id, name: user.name, email: user.email, first_name: user.first_name, last_name: user.last_name, provider_permissions: user.provider_permissions }
      end
    end
  end
end
