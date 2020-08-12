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

        payload = {
            page_number: filter_params.page_number,
            number_per_page: filter_params.count_per_page,
            is_paused: filter_params.paused,
            pause_reason: filter_params.pause_reason,
            full_patch: filter_params.full_patch,
            upcoming_court_dates: filter_params.upcoming_court_dates,
            upcoming_evictions: filter_params.upcoming_evictions,
            recommended_actions: filter_params.recommended_actions,
            patch: filter_params.patch_code,
            service_area_type: filter_params.service_area_type
        }.reject { |_k, v| v.nil? }

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
