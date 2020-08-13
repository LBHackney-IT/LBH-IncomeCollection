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

      def view_court_cases(tenancy_ref:)
        uri = URI.parse("#{@api_host}/v1/court_cases/#{ERB::Util.url_encode(tenancy_ref)}/")
        req = Net::HTTP::Get.new(uri.path)
        req['Content-Type'] = 'application/json'
        req['X-Api-Key'] = @api_key

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req) }

        raise_error(response, "when trying to get court cases using '#{uri}'")
        
        court_cases = JSON.parse(response.body)['courtCases']

        court_cases.map do |court_case|
          Hackney::Income::Domain::CourtCase.new.tap do |t|
            t.id = court_case['id']
            t.tenancy_ref = court_case['tenancyRef']
            t.court_date = court_case['courtDate']
            t.court_outcome = court_case['courtOutcome']
            t.balance_on_court_outcome_date = court_case['balanceOnCourtOutcomeDate']
            t.strike_out_date = court_case['strikeOutDate']
            t.terms = court_case['terms']
            t.disrepair_counter_claim = court_case['disrepairCounterClaim']
          end
        end
      end

      private

      def raise_error(response, message)
        raise Exceptions::IncomeApiError.new(response), message unless response.is_a? Net::HTTPSuccess
      end
    end
  end
end
