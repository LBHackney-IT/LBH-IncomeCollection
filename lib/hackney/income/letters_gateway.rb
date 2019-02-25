module Hackney
  module Income
    class LettersGateway
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def send_letter(tenancy_ref:, template_id:, user_id:)
        uri = URI("#{@api_host}v1/letters/send_letter")
        body_data = {
          tenancy_ref: tenancy_ref,
          template_id: template_id,
          user_id: user_id
        }.to_json

        req = Net::HTTP::Post.new(uri)
        req['X-Api-Key'] = @api_key
        req['Content-Type'] = 'application/json'

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req, body_data) }
        unless res.is_a? Net::HTTPSuccess
          raise Exceptions::IncomeApiError.new(res), 'error sending letter'
        end

        res
      end

      def get_letter_templates
        uri = URI("#{@api_host}v1/letters/get_templates")

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
