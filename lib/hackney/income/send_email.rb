module Hackney
  module Income
    class SendEmail
      def initialize(tenancy_gateway:, notification_gateway:)
        @tenancy_gateway = tenancy_gateway
        @notification_gateway = notification_gateway
      end

      def execute(tenancy_ref:, template_id:, subject:)
        tenancy = @tenancy_gateway.get_tenancy(tenancy_ref: tenancy_ref)

        @notification_gateway.send_email(
          recipient: tenancy.dig(:primary_contact, :email_address),
          subject: subject,
          template_id: template_id,
          reference: reference_for(tenancy),
          variables: variables_for(tenancy)
        )
      end

      private

      def reference_for(tenancy)
        "manual_#{tenancy.fetch(:ref)}"
      end

      def variables_for(tenancy)
        {
          'first name' => tenancy.dig(:primary_contact, :first_name)
        }
      end
    end
  end
end
