require 'uri'
require 'net/http'

module Hackney
  module Income
    class CourtCasesGateway
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def create_court_case(create_court_case_params:)
        tenancy_ref = create_court_case_params[:tenancy_ref]

        body_data = {
          court_date: create_court_case_params[:court_date],
          court_outcome: create_court_case_params[:court_outcome],
          balance_on_court_outcome_date: create_court_case_params[:balance_on_court_outcome_date],
          strike_out_date: create_court_case_params[:strike_out_date],
          terms: create_court_case_params[:terms],
          disrepair_counter_claim: create_court_case_params[:disrepair_counter_claim]
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
