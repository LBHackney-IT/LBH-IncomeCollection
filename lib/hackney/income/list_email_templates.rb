module Hackney
  module Income
    class ListEmailTemplates
      def initialize(notifications_gateway:, tenancy_gateway:)
        @notifications_gateway = notifications_gateway
        @tenancy_gateway = tenancy_gateway
      end

      def execute(tenancy_ref:)
        tenancy = @tenancy_gateway.get_tenancy(tenancy_ref: tenancy_ref)

        @notifications_gateway.get_email_templates.map do |template|
          EmailTemplate.new(
            id: template.fetch(:id),
            name: template.fetch(:name),
            body: fill_in_values(template.fetch(:body), tenancy),
            subject: fill_in_values(template.fetch(:subject), tenancy)
          )
        end
      end

      private

      def fill_in_values(template_body, tenancy)
        TemplateReplacer.new.replace(template_body, {
          'first name' => tenancy.dig(:primary_contact, :first_name)
        })
      end
    end
  end
end
