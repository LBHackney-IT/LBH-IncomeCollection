module Hackney
  module Income
    class GetLetterPreview
      def initialize(letters_gateway:)
        @letters_gateway = letters_gateway
      end

      def execute(pay_ref:, template_id:, user:)
        @letters_gateway.create_letter_preview(
          payment_ref: pay_ref,
          template_id: template_id,
          user: user
        )
      rescue Exceptions::IncomeApiError::NotFoundError
        Rails.logger.info("'#{self.class.name}' Exception: Payment ref ''#{pay_ref}' not found'")
        { status_code: 404 }
      end
    end
  end
end
