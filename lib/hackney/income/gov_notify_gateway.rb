module Hackney
  module Income
    class GovNotifyGateway
      def initialize(api_host:, api_key:, sms_sender_id:)
        @api_host = api_host
        @api_key = api_key
        @sms_sender_id = sms_sender_id
      end

      def send_text_message(tenancy_ref:, phone_number:, template_id:, username:, reference:, variables:)
        uri = URI("#{@api_host}v1/messages/send_sms")
        body_data = {
          tenancy_ref: tenancy_ref,
          phone_number: phone_number,
          template_id: template_id,
          variables: variables,
          reference: reference,
          sms_sender_id: @sms_sender_id,
          username: username
        }.to_json

        req = Net::HTTP::Post.new(uri)
        req['X-Api-Key'] = @api_key
        req['Content-Type'] = 'application/json'

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req, body_data) }

        raise Exceptions::IncomeApiError.new(res), "Failed to send sms: Invalid phone number provided: #{phone_number}" unless res.is_a? Net::HTTPSuccess

        res
      end

      def send_email(tenancy_ref:, recipient:, template_id:, reference:, variables:, username:)
        uri = URI("#{@api_host}v1/messages/send_email")
        body_data = {
          tenancy_ref: tenancy_ref,
          email_address: recipient,
          template_id: template_id,
          variables: variables,
          reference: reference,
          username: username
        }.to_json

        req = Net::HTTP::Post.new(uri)
        req['X-Api-Key'] = @api_key
        req['Content-Type'] = 'application/json'
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req, body_data) }
        raise Exceptions::IncomeApiError.new(res), 'error sending email' unless res.is_a? Net::HTTPSuccess

        res
      end

      def get_text_templates
        uri = URI("#{@api_host}v1/messages/get_templates")
        uri.query = URI.encode_www_form('type' => 'sms')

        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key
        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req) }

        raise Exceptions::IncomeApiError.new(res), "when trying to get_text_templates '#{uri}'" unless res.is_a? Net::HTTPSuccess

        JSON.parse(res.body).map(&:deep_symbolize_keys)
      end

      def get_email_templates
        uri = URI("#{@api_host}v1/messages/get_templates")
        uri.query = URI.encode_www_form('type' => 'email')

        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key
        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req) }

        raise Exceptions::IncomeApiError.new(res), "when trying to get_email_templates '#{uri}'" unless res.is_a? Net::HTTPSuccess

        JSON.parse(res.body).map(&:deep_symbolize_keys)
      end
    end
  end
end
