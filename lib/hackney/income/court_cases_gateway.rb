require 'uri'
require 'net/http'

module Hackney
  module Income
    class CourtCasesGateway
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def create_court_case(tenancy_ref:, date_of_court_decision:, court_outcome:, balance_on_court_outcome_date:, strike_out_date:, created_by:)
        body_data = {
          court_decision_date: date_of_court_decision,
          court_outcome: court_outcome,
          balance_at_outcome_date: balance_on_court_outcome_date,
          strike_out_date: strike_out_date,
          created_by: created_by
        }.to_json

        uri = URI.parse("#{@api_host}/v1/court_case/#{ERB::Util.url_encode(tenancy_ref)}/")
        req = Net::HTTP::Post.new(uri.path)
        req['Content-Type'] = 'application/json'
        req['X-Api-Key'] = @api_key

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req, body_data) }

        raise_error(response, "when trying to create a new court case using '#{uri}'")

        response.body
      end

      private

      def raise_error(response, message)
        raise Exceptions::IncomeApiError.new(response), message unless response.is_a? Net::HTTPSuccess
      end
    end
  end
end
