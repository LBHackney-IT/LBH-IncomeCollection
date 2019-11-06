module Hackney
  module Income
    class SendEmail
      def initialize(tenancy_gateway:, notification_gateway:)
        @tenancy_gateway = tenancy_gateway
        @notification_gateway = notification_gateway
      end

      def execute(email_addresses:, tenancy_ref:, template_id:, username:)
        tenancy = @tenancy_gateway.get_tenancy(tenancy_ref: tenancy_ref)

        email_addresses.uniq.each do |email_address|
          @notification_gateway.send_email(
            tenancy_ref: tenancy_ref,
            recipient: email_address,
            template_id: template_id,
            username: username,
            reference: reference_for(tenancy),
            variables: Hackney::TemplateVariables.variables_for(tenancy)
          )
        end
      end

      private

      def reference_for(tenancy)
        "manual_#{tenancy.ref}"
      end
    end
  end
end
