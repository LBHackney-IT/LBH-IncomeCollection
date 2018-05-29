module Hackney
  module Income
    class StubNotificationsGateway
      attr_reader :last_text_message, :last_email

      def initialize(templates: DEFAULT_TEMPLATES, sms_sender_id: nil, email_reply_to_id: nil, api_key: nil, last_text_message: nil)
        @templates = templates
        @last_text_message = nil
        @last_email = nil
      end

      def get_text_templates
        @templates
      end

      def get_email_templates
        @templates
      end

      def send_text_message(phone_number:, template_id:, reference:, variables:)
        @last_text_message = {
          phone_number: phone_number,
          template_id: template_id,
          reference: reference,
          variables: variables
        }
      end

      def send_email(recipient:, subject:, template_id:, reference:, variables:)
        @last_email = {
          recipient: recipient,
          subject: subject,
          template_id: template_id,
          reference: reference,
          variables: variables
        }
      end

      private

      DEFAULT_TEMPLATES = [
        { id: '00001', name: 'Quick Template', body: 'quick ((first name))!' },
        { id: '00002', name: 'Where Are You?', body: 'where are you from ((title)) ((last name))??' }
      ]
    end
  end
end
