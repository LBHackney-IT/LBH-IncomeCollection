require 'uri'
require 'net/http'

module Hackney
  module Income
    class AgreementsGateway
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def create_agreement(tenancy_ref:, agreement_type:, frequency:, amount:, start_date:, created_by:, notes:, court_case_id:, initial_payment_amount:, initial_payment_date:)
        body_data = {
          agreement_type: agreement_type,
          frequency: frequency,
          amount: amount,
          start_date: start_date,
          created_by: created_by,
          notes: notes,
          court_case_id: court_case_id,
          initial_payment_amount: initial_payment_amount,
          initial_payment_date: initial_payment_date
        }.to_json

        uri = URI.parse("#{@api_host}/v1/agreement/#{ERB::Util.url_encode(tenancy_ref)}/")
        req = Net::HTTP::Post.new(uri.path)
        req['Content-Type'] = 'application/json'
        req['X-Api-Key'] = @api_key

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req, body_data) }

        raise_error(response, "when trying to create a new agreement using '#{uri}'")

        map_response_to_agreement_domain(JSON.parse(response.body))
      end

      def view_agreements(tenancy_ref:)
        uri = URI.parse("#{@api_host}/v1/agreements/#{ERB::Util.url_encode(tenancy_ref)}/")
        req = Net::HTTP::Get.new(uri.path)
        req['Content-Type'] = 'application/json'
        req['X-Api-Key'] = @api_key

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req) }

        raise_error(response, "when trying to get agreements using '#{uri}'")

        agreements = JSON.parse(response.body)['agreements']

        agreements.map do |agreement|
          map_response_to_agreement_domain(agreement)
        end
      end

      def cancel_agreement(agreement_id:, cancelled_by:, cancellation_reason:)
        body_data = {
          cancelled_by: cancelled_by,
          cancellation_reason: cancellation_reason
        }.to_json

        uri = URI.parse("#{@api_host}/v1/agreements/#{ERB::Util.url_encode(agreement_id)}/cancel")
        req = Net::HTTP::Post.new(uri.path)
        req['Content-Type'] = 'application/json'
        req['X-Api-Key'] = @api_key

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req, body_data) }

        raise_error(response, "when trying to cancel the agreement using '#{uri}'")

        response.body
      end

      private

      def raise_error(response, message)
        raise Exceptions::IncomeApiError.new(response), message unless response.is_a? Net::HTTPSuccess
      end

      def map_response_to_agreement_domain(agreement)
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
          t.last_checked = agreement['lastChecked']
          t.notes = agreement['notes']
          t.initial_payment_amount = agreement['initialPaymentAmount']
          t.initial_payment_date = agreement['initialPaymentDate']
          t.history = agreement['history'].map do |state|
            Hackney::Income::Domain::AgreementState.new.tap do |s|
              s.date = state['date']
              s.state = state['state']
              s.expected_balance = state['expectedBalance']
              s.checked_balance = state['checkedBalance']
              s.description = state['description']
            end
          end
        end
      end
    end
  end
end
