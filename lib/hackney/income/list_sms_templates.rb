module Hackney
  module Income
    class ListSmsTemplates
      def initialize(notifications_gateway:, tenancy_gateway:)
        @notifications_gateway = notifications_gateway
        @tenancy_gateway = tenancy_gateway
      end

      def execute(tenancy_ref:)
        tenancy = @tenancy_gateway.get_tenancy(tenancy_ref: tenancy_ref)

        @notifications_gateway.get_text_templates.map do |template|
          SmsTemplate.new(
            id: template.fetch(:id),
            name: template.fetch(:name),
            body: Hackney::TemplateValueHelper.fill_in_values(template.fetch(:body), tenancy)
          )
        end
      end
    end
  end
end
