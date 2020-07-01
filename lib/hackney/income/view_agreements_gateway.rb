require 'uri'
require 'net/http'

module Hackney
  module Income
    class ViewAgreementsGateway
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def view_agreements(tenancy_ref:)
        uri = URI.parse("#{@api_host}/v1/agreements/#{ERB::Util.url_encode(tenancy_ref)}/")
        req = Net::HTTP::Get.new(uri.path)
        req['Content-Type'] = 'application/json'
        req['X-Api-Key'] = @api_key

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req) }

        raise Exceptions::IncomeApiError.new(response), "when trying to get agreements using '#{uri}'" unless response.is_a? Net::HTTPSuccess

        agreements = JSON.parse(response.body)['agreements']

        agreements.map do |agreement|
          Hackney::Income::Domain::Agreement.new.tap do |t|
            t.id = agreement['id']
            t.tenancy_ref = agreement['tenancyRef']
            t.agreement_type = agreement['agreementType']
            t.starting_balance = agreement['startingBalance']
            t.amount = agreement['amount']
            t.start_date = agreement['startDate']
            t.frequency = agreement['frequency']
            t.current_state = agreement['currentState']
            t.created_at = agreement['createdAt']
            t.created_by = agreement['createdBy']
            t.history = agreement['history'].map do |state|
              Hackney::Income::Domain::AgreementState.new.tap do |s|
                s.date = state['date']
                s.state = state['state']
              end
            end
          end
        end
      end
    end
  end
end
