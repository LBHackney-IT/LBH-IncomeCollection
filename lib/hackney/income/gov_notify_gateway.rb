require 'notifications/client'

module Hackney
  module Income
    class GovNotifyGateway
      # def initialize(sms_sender_id:, api_key:)
      #   @sms_sender_id = sms_sender_id
      #   @client = Notifications::Client.new(api_key)
      # end
      def initialize(api_host:, api_key:, sms_sender_id:)
        @api_host = api_host
        @api_key = api_key
        @sms_sender_id = sms_sender_id

        # sms_sender_id: ENV['GOV_NOTIFY_SENDER_ID'],
        # @sms_sender_id = sms_sender_id
        @client = Notifications::Client.new(ENV['GOV_NOTIFY_API_KEY'])
      end

      def send_text_message(phone_number:, template_id:, reference:, variables:)
        uri = URI("#{@api_host}/messages/send_sms")
        uri.query = URI.encode_www_form(
          phone_number: pre_release_phone_number(phone_number),
          template_id: template_id,
          personalisation: variables,
          reference: reference,
          sms_sender_id: @sms_sender_id
        )

        req = Net::HTTP::Post.new(uri)
        req['X-Api-Key'] = @api_key

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

        unless res.is_a? Net::HTTPSuccess
          raise Exceptions::IncomeApiError.new(res), "error sending sms"
        end

        res
      end

      def send_email(recipient:, template_id:, reference:, variables:)
        @client.send_email(
          email_address: pre_release_email(recipient),
          template_id: template_id,
          personalisation: variables,
          reference: reference
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

      private

      def pre_release_phone_number(phone_number)
        return phone_number if send_for_real?
        ENV['TEST_PHONE_NUMBER']
      end

      def pre_release_email(email)
        return email if send_for_real?
        ENV['TEST_EMAIL_ADDRESS']
      end

      def send_for_real?
        ENV['SEND_LIVE_COMMUNICATIONS'] == 'true'
      end
    end
  end
end
