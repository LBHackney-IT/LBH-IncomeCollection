module Hackney
  module Income
    class SendSms
      def initialize(tenancy_gateway:, notification_gateway:, events_gateway:)
        @tenancy_gateway = tenancy_gateway
        @notification_gateway = notification_gateway
        @events_gateway = events_gateway
      end

      def execute(tenancy_ref:, template_id:)
        tenancy = @tenancy_gateway.get_tenancy(tenancy_ref: tenancy_ref)

        @notification_gateway.send_text_message(
          phone_number: contact_number_for(tenancy),
          template_id: template_id,
          reference: reference_for(tenancy),
          variables: Hackney::TemplateVariables.variables_for(tenancy)
        )

        @events_gateway.create_event(
          tenancy_ref: tenancy_ref,
          type: 'sms_message_sent',
          description: "Sent SMS message to #{contact_number_for(tenancy)}",
          automated: false
        )
      end

      private

      def contact_number_for(tenancy)
        tenancy.dig(:primary_contact, :contact_number)
      end

      def reference_for(tenancy)
        "manual_#{tenancy.fetch(:ref)}"
      end
    end
  end
end
