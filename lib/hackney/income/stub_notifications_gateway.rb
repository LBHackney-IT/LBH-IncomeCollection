module Hackney
  module Income
    class StubNotificationsGateway
      DEFAULT_TEMPLATES = [
        { id: '00001', name: 'Quick Template', body: 'quick ((first name))!', subject: nil },
        { id: '00002', name: 'Where Are You?', body: 'where are you from ((title)) ((last name))??', subject: nil },
        { id: '00003', name: 'Email', body: 'Sending emails is cool and fun', subject: 'Hi ((name))!' }
      ].freeze

      private_constant :DEFAULT_TEMPLATES
      attr_reader :last_text_message, :last_email

      def initialize(templates: DEFAULT_TEMPLATES, sms_sender_id: nil, api_key: nil, last_text_message: nil)
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

      def send_email(recipient:, template_id:, reference:, variables:)
        @last_email = {
          recipient: recipient,
          template_id: template_id,
          reference: reference,
          variables: variables
        }
      end
    end
  end
end
