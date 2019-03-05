module Hackney
  module Income
    class GetLetterPreview
      def initialize(letters_gateway:)
        @letters_gateway = letters_gateway
      end

      def execute(pay_ref:, template_id:, user_id:)
        @letters_gateway.send_letter(
          payment_ref: pay_ref,
          template_id: template_id,
          user_id: user_id
        )
      rescue Exceptions::IncomeApiError::NotFoundError
        Rails.logger.info("'#{self.class.name}' Exception: Payment ref ''#{pay_ref}' not found'")
        { status_code: 404 }
      end
    end
  end
end
