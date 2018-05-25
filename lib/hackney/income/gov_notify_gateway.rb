require 'notifications/client'

module Hackney
  module Income
    class GovNotifyGateway
      def initialize(sms_sender_id:, api_key:)
        @sms_sender_id = sms_sender_id
        @client = Notifications::Client.new(api_key)
      end

      def send_text_message(phone_number:, template_id:, reference:, variables:)
        @client.send_sms(
          phone_number: phone_number,
          template_id: template_id,
          personalisation: variables,
          reference: reference,
          sms_sender_id: @sms_sender_id
        )
      end

      def get_text_templates
        @client.get_all_templates(type: 'sms').collection.map do |template|
          { id: template.id, name: template.name, body: template.body }
        end
      end
    end
  end
end
