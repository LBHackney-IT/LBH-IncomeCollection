require 'uri'
require 'net/http'

module Hackney
  module Income
    class EvictionGateway
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def create_eviction(params:)
        tenancy_ref = params[:tenancy_ref]

        body_data = {
            date: params[:date]
        }.to_json

        uri = URI.parse("#{@api_host}/v1/eviction/#{ERB::Util.url_encode(tenancy_ref)}/")
        req = Net::HTTP::Post.new(uri.path)
        req['Content-Type'] = 'application/json'
        req['X-Api-Key'] = @api_key

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req, body_data) }

        raise Exceptions::IncomeApiError.new(response), "when trying to create a new eviction date using '#{uri}'" unless response.is_a? Net::HTTPSuccess

        response.body
      end
    end
  end
end
