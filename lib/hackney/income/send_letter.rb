module Hackney
  module Income
    class SendLetter
      def initialize(letters_gateway:)
        @letters_gateway = letters_gateway
      end

      def execute(uuid:, user:, tenancy_ref:)
        @letters_gateway.send_letter(
          uuid: uuid,
          user: user,
          tenancy_ref: tenancy_ref
        )
      rescue Exceptions::IncomeApiError::NotFoundError
        Rails.logger.info("'#{self.class.name}' Exception: Preview uuid '#{uuid}' not found'")
        { status_code: 404 }
      end
    end
  end
end
