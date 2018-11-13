module Hackney
  module Income
    class SendEmail
      def initialize(tenancy_gateway:, notification_gateway:)
        @tenancy_gateway = tenancy_gateway
        @notification_gateway = notification_gateway
      end

      def execute(tenancy_ref:, template_id:)
        tenancy = @tenancy_gateway.get_tenancy(tenancy_ref: tenancy_ref)

        # FIXME: currently don't get email addresses!
        @notification_gateway.send_email(
          tenancy_ref: tenancy_ref,
          recipient: tenancy.primary_contact_email,
          template_id: template_id,
          reference: reference_for(tenancy),
          variables: Hackney::TemplateVariables.variables_for(tenancy)
        )
      end

      private

      def reference_for(tenancy)
        "manual_#{tenancy.ref}"
      end
    end
  end
end
