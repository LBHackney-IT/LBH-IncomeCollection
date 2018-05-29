require 'notifications/client'

module Hackney
  module Income
    class GovNotifyGateway
      def initialize(sms_sender_id:, email_reply_to_id:, api_key:)
        @sms_sender_id = sms_sender_id
        @email_reply_to_id = email_reply_to_id
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

      def send_email(recipient:, template_id:, reference:, variables:)
        @client.send_email(
          email_address: recipient,
          template_id: template_id,
          personalisation: variables,
          reference: reference,
          # email_reply_to_id: @email_reply_to_id
        )
      end

      def get_text_templates
        @client.get_all_templates(type: 'sms').collection.map do |template|
          { id: template.id, name: template.name, body: template.body }
        end
      end

      def get_email_templates
        @client.get_all_templates(type: 'email').collection.map do |template|
          { id: template.id, name: template.name, body: template.body, subject: template.subject }
        end
      end
    end
  end
end
