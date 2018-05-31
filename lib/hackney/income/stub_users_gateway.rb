module Hackney
  module Income
    class StubUsersGateway
      def initialize
        @id = 0
      end

      def find_or_create_user(provider_uid:, provider:, name:, email:, first_name:, last_name:)
        { id: @id += 1,  name: name }
      end
    end
  end
end
