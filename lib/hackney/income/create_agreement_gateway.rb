require 'uri'
require 'net/http'

module Hackney
  module Income
    class CreateAgreementGateway
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def create_agreement(tenancy_ref:, agreement_type:, frequency:, amount:, start_date:, created_by:)
        body_data = {
          agreement_type: agreement_type,
          frequency: frequency,
          amount: amount,
          start_date: start_date,
          created_by: created_by
        }.to_json

        uri = URI.parse("#{@api_host}/v1/agreement/#{ERB::Util.url_encode(tenancy_ref)}/")
        req = Net::HTTP::Post.new(uri.path)
        req['Content-Type'] = 'application/json'
        req['X-Api-Key'] = @api_key

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req, body_data) }

        raise Exceptions::IncomeApiError.new(response), "when trying to create a new agreement using '#{uri}'" unless response.is_a? Net::HTTPSuccess

        response.body
      end
    end
  end
end
