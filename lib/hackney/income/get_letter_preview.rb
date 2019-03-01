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
      end
    end
  end
end
