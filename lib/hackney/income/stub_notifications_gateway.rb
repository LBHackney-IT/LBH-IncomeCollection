module Hackney
  module Income
    class StubNotificationsGateway
      attr_reader :last_text_message

      def initialize(templates: DEFAULT_TEMPLATES, sms_sender_id: nil, api_key: nil, last_text_message: nil)
        @templates = templates
        @last_text_message = nil
      end

      def get_text_templates
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

      private

      DEFAULT_TEMPLATES = [
        { id: '00001', name: 'Quick Template', body: 'quick ((first name))!' },
        { id: '00002', name: 'Where Are You?', body: 'where are you from ((title)) ((last name))??' }
      ]
    end
  end
end
