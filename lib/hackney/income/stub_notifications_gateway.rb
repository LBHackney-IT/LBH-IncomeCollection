module Hackney
  module Income
    class StubNotificationsGateway
      def initialize(templates: DEFAULT_TEMPLATES, sms_sender_id: nil, api_key: nil)
        @templates = templates
      end

      def get_text_templates
        @templates
      end

      private

      DEFAULT_TEMPLATES = [
        { id: '00001', name: 'Quick Template', body: 'quick ((first name))!' },
        { id: '00002', name: 'Where Are You?', body: 'where are you from ((title)) ((last name))??' }
      ]
    end
  end
end
