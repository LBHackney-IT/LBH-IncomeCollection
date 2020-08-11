require 'net/http'
require 'uri'

module Hackney
  module Income
    class ActionsGateway
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      # Income API
      def get_actions(filter_params:)
        uri = URI("#{@api_host}/v1/actions")

        payload = filter_params.to_params
        uri.query = URI.encode_www_form(payload)

        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req) }

        raise Exceptions::IncomeApiError.new(res), "when trying to get_actions for Params '#{filter_params.to_params.inspect}'" unless res.is_a? Net::HTTPSuccess

        JSON.parse(res.body).deep_symbolize_keys
      end
    end
  end
end
