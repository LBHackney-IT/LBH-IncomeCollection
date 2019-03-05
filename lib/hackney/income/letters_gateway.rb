module Hackney
  module Income
    class LettersGateway
      SEND_LETTER_ENDPOINT = 'v1/pdf/send_letter'.freeze
      GET_LETTER_TEMPLATES_ENDPOINT = 'v1/pdf/get_templates'.freeze

      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def send_letter(payment_ref:, template_id:, user_id:)
        uri = URI("#{@api_host}#{SEND_LETTER_ENDPOINT}")
        body_data = {
          payment_ref: payment_ref,
          template_id: template_id,
          user_id: user_id
        }.to_json

        req = Net::HTTP::Post.new(uri)
        req['X-Api-Key'] = @api_key
        req['Content-Type'] = 'application/json'

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req, body_data) }
        raise Exceptions::IncomeApiError::NotFoundError.new(res), "when trying to send_letter with payment_ref: '#{payment_ref}'" if res.is_a? Net::HTTPNotFound
        unless res.is_a? Net::HTTPSuccess
          raise Exceptions::IncomeApiError.new(res), 'error sending letter'
        end

        JSON.parse(res.body).deep_symbolize_keys
      end

      def get_letter_templates
        uri = URI("#{@api_host}#{GET_LETTER_TEMPLATES_ENDPOINT}")

        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key
        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

        unless res.is_a? Net::HTTPSuccess
          raise Exceptions::IncomeApiError.new(res), "when trying to get_letter_templates '#{uri}'"
        end

        JSON.parse(res.body).map(&:deep_symbolize_keys)
      end
    end
  end
end