module Hackney
  module Income
    class SendSms
      def initialize(tenancy_gateway:, notification_gateway:)
        @tenancy_gateway = tenancy_gateway
        @notification_gateway = notification_gateway
      end

      def execute(phone_numbers:, tenancy_ref:, user_id:, template_id:)
        tenancy = @tenancy_gateway.get_tenancy(tenancy_ref: tenancy_ref)

        phone_numbers.uniq.each do |phone_number|
          @notification_gateway.send_text_message(
            tenancy_ref: tenancy_ref,
            phone_number: phone_number,
            user_id: user_id,
            template_id: template_id,
            reference: reference_for(tenancy),
            variables: Hackney::TemplateVariables.variables_for(tenancy)
          )
        end
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
