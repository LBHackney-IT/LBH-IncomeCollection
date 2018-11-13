require 'notifications/client'

module Hackney
  module Income
    class GovNotifyGateway

      def initialize(api_host:, api_key:, sms_sender_id:)
        @api_host = api_host
        @api_key = api_key
        @sms_sender_id = sms_sender_id
      end

      def send_text_message(tenancy_ref:, phone_number:, template_id:, reference:, variables:)
        uri = URI("#{@api_host}/messages/send_sms")
        body_data = {
          tenancy_ref: tenancy_ref,
          phone_number: pre_release_phone_number(phone_number),
          template_id: template_id,
          variables: variables,
          reference: reference,
          sms_sender_id: @sms_sender_id
        }.to_json

        req = Net::HTTP::Post.new(uri)
        req['X-Api-Key'] = @api_key
        req['Content-Type'] = 'application/json'

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req, body_data) }
        unless res.is_a? Net::HTTPSuccess
          raise Exceptions::IncomeApiError.new(res), 'error sending sms'
        end

        res
      end

      def send_email(tenancy_ref:, recipient:, template_id:, reference:, variables:)
        uri = URI("#{@api_host}/messages/send_email")
        body_data = {
          tenancy_ref: tenancy_ref,
          email_address: pre_release_email(recipient),
          template_id: template_id,
          variables: variables,
          reference: reference
        }.to_json

        req = Net::HTTP::Post.new(uri)
        req['X-Api-Key'] = @api_key
        req['Content-Type'] = 'application/json'
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req, body_data) }
        unless res.is_a? Net::HTTPSuccess
          raise Exceptions::IncomeApiError.new(res), 'error sending email'
        end

        res
      end

      def get_text_templates
        uri = URI("#{@api_host}/messages/get_templates")
        uri.query = URI.encode_www_form('type' => 'sms')

        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key
        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

        JSON.parse(res.body)
      end

      def get_email_templates
        uri = URI("#{@api_host}/messages/get_templates")
        uri.query = URI.encode_www_form('type' => 'email')

        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key
        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

        JSON.parse(res.body)
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
