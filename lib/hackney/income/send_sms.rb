module Hackney
  module Income
    class SendSms
      def initialize(notification_gateway:)
        @notification_gateway = notification_gateway
      end

      def execute(tenancy:, template_id:)
        @notification_gateway.send_text_message(
          phone_number: tenancy.primary_contact.fetch(:contact_number),
          template_id: template_id,
          reference: reference_for(tenancy),
          variables: variables_for(tenancy)
        )
      end

      private

      def reference_for(tenancy)
        "manual_#{tenancy.ref}"
      end

      def variables_for(tenancy)
        {
          'first name' => tenancy.primary_contact.fetch(:first_name)
        }
      end
    end
  end
end
