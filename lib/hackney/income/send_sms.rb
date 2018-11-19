module Hackney
  module Income
    class SendSms
      def initialize(tenancy_gateway:, notification_gateway:, events_gateway:)
        @tenancy_gateway = tenancy_gateway
        @notification_gateway = notification_gateway
        @events_gateway = events_gateway
      end

      def execute(phone_numbers:, tenancy_ref:, template_id:)
        tenancy = @tenancy_gateway.get_tenancy(tenancy_ref: tenancy_ref)

        phone_numbers.each do |phone_number|
          @notification_gateway.send_text_message(
            tenancy_ref: tenancy_ref,
            phone_number: phone_number,
            template_id: template_id,
            reference: reference_for(tenancy),
            variables: Hackney::TemplateVariables.variables_for(tenancy)
          )
        end

        @events_gateway.create_event(
          tenancy_ref: tenancy_ref,
          type: 'sms_message_sent',
          description: "Sent SMS message to #{contact_number_for(tenancy)}",
          automated: false
        )
      end

      private

      def contact_number_for(tenancy)
        tenancy.primary_contact_phone
      end

      def reference_for(tenancy)
        "manual_#{tenancy.ref}"
      end
    end
  end
end
