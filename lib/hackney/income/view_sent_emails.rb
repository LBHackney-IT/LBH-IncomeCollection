module Hackney
  module Income
    class ViewSentEmails
      def initialize(notifications_gateway:)
        @notifications_gateway = notifications_gateway
      end

      def execute(tenancy_ref:)
        @notifications_gateway.view_sent_emails(tenancy_ref: tenancy_ref)
      end
    end
  end
end
