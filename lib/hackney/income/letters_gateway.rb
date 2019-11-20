module Hackney
  module Income
    class LettersGateway
      CREATE_LETTER_PREVIEW_ENDPOINT = 'v1/messages/letters'.freeze
      GET_LETTER_TEMPLATES_ENDPOINT = 'v1/messages/letters/get_templates'.freeze
      SEND_LETTER_ENDPOINT = 'v1/messages/letters/send'.freeze

      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def create_letter_preview(template_id:, user:, payment_ref: nil, tenancy_ref: nil)
        raise ArgumentError, 'payment_ref or tenancy_ref must be supplied' if [payment_ref, tenancy_ref].all?(&:blank?)

        uri = URI("#{@api_host}#{CREATE_LETTER_PREVIEW_ENDPOINT}")
        body_data = {
          payment_ref: payment_ref,
          tenancy_ref: tenancy_ref,
          template_id: template_id,
          user: user
        }.to_json

        req = Net::HTTP::Post.new(uri)
        req['X-Api-Key'] = @api_key
        req['Content-Type'] = 'application/json'

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req, body_data) }

        raise Exceptions::IncomeApiError::NotFoundError.new(res), "when trying to send_letter with payment_ref: '#{payment_ref}'" if res.is_a? Net::HTTPNotFound
        unless res.is_a? Net::HTTPSuccess
          raise Exceptions::IncomeApiError.new(res), 'error sending letter'
        end

        JSON.parse(res.body).deep_symbolize_keys
      end

      def send_letter(uuid:, user:)
        uri = URI("#{@api_host}#{SEND_LETTER_ENDPOINT}")
        body_data = {
          uuid: uuid,
          user: user
        }.to_json

        req = Net::HTTP::Post.new(uri)
        req['X-Api-Key'] = @api_key
        req['Content-Type'] = 'application/json'

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req, body_data) }
        raise Exceptions::IncomeApiError::NotFoundError.new(res), "when trying to send_letter with uuid: '#{uuid}'" if res.is_a? Net::HTTPNotFound
        unless res.is_a? Net::HTTPSuccess
          raise Exceptions::IncomeApiError.new(res), 'error sending letter'
        end

        res
      end

      def get_letter_templates(user:)
        uri = URI("#{@api_host}#{GET_LETTER_TEMPLATES_ENDPOINT}")
        uri.query = user.to_query(:user)

        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key
        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req) }

        unless res.is_a? Net::HTTPSuccess
          raise Exceptions::IncomeApiError.new(res), "when trying to get_letter_templates '#{uri}'"
        end

        JSON.parse(res.body).map(&:deep_symbolize_keys)
      end
    end
  end
end
