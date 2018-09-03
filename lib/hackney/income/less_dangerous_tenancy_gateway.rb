require 'uri'

module Hackney
  module Income
    class LessDangerousTenancyGateway
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def get_tenancies_list(refs:)
        response = RestClient.get(
          "#{@api_host}/tenancies",
          'x-api-key' => @api_key,
          params: { tenancy_refs: convert_to_params_array(refs: refs) }
        )
        tenancies = JSON.parse(response.body)['tenancies']

        tenancies.map do |tenancy|
          t = Hackney::Income::Domain::TenancyListItem.new
          t.ref = tenancy['ref']
          t.current_balance = tenancy['current_balance'].delete('¤').to_f
          t.current_arrears_agreement_status = tenancy['current_arrears_agreement_status']
          t.latest_action_code = tenancy['latest_action']['code']
          t.latest_action_date = tenancy['latest_action']['date']
          t.primary_contact_name = tenancy['primary_contact']['name']
          t.primary_contact_short_address = tenancy['primary_contact']['short_address']
          t.primary_contact_postcode = tenancy['primary_contact']['postcode']

          return Hackney::Income::Anonymizer.anonymize_tenancy_list_item(tenancy: t) if Rails.env.staging?
          t
        end
      end

      def temp_case_list
        response = RestClient.get(
          "#{@api_host}/my-cases",
          'x-api-key' => @api_key,
          'timeout' => 30
        )
        tenancies = JSON.parse(response.body)

        result = []
        tenancies.each do |tenancy|
          t = Hackney::Income::Domain::TenancyListItem.new
          t.ref = tenancy['ref']
          t.current_balance = tenancy['current_balance'].delete('¤').to_f
          t.current_arrears_agreement_status = tenancy['current_arrears_agreement_status']
          t.latest_action_code = tenancy['latest_action']['code']
          t.latest_action_date = tenancy['latest_action']['date']
          t.primary_contact_name = tenancy['primary_contact']['name']
          t.primary_contact_short_address = tenancy['primary_contact']['short_address']
          t.primary_contact_postcode = tenancy['primary_contact']['postcode']
          t.score = tenancy['priority_score']
          t.band = tenancy['priority_band']

          t.balance_contribution = tenancy['balance_contribution']
          t.days_in_arrears_contribution = tenancy['days_in_arrears_contribution']
          t.days_since_last_payment_contribution = tenancy['days_since_last_payment_contribution']
          t.payment_amount_delta_contribution = tenancy['payment_amount_delta_contribution']
          t.payment_date_delta_contribution = tenancy['payment_date_delta_contribution']
          t.number_of_broken_agreements_contribution = tenancy['number_of_broken_agreements_contribution']
          t.active_agreement_contribution = tenancy['active_agreement_contribution']
          t.broken_court_order_contribution = tenancy['broken_court_order_contribution']
          t.nosp_served_contribution = tenancy['nosp_served_contribution']
          t.active_nosp_contribution = tenancy['active_nosp_contribution']

          t.days_in_arrears = tenancy['days_in_arrears']
          t.days_since_last_payment = tenancy['days_since_last_payment']
          t.payment_amount_delta = tenancy['payment_amount_delta']
          t.payment_date_delta = tenancy['payment_date_delta']
          t.number_of_broken_agreements = tenancy['number_of_broken_agreements']
          t.broken_court_order = tenancy['broken_court_order']
          t.nosp_served = tenancy['nosp_served']
          t.active_nosp = tenancy['active_nosp']

          Hackney::Income::Anonymizer.anonymize_tenancy_list_item(tenancy: t) if Rails.env.staging?

          result << t
        end

        result
      end

      def convert_to_params_array(refs:)
        RestClient::ParamsArray.new(refs.map.with_index(0) { |e, i| [i, e] }.to_a)
      end

      def get_tenancy(tenancy_ref:)
        response = RestClient.get(
          "#{@api_host}/tenancies/#{ERB::Util.url_encode(tenancy_ref)}",
          'x-api-key' => @api_key
        )
        tenancy = JSON.parse(response.body)

        tenancy_item = Hackney::Income::Domain::Tenancy.new.tap do |t|
          t.ref = tenancy['tenancy_details']['ref']
          t.current_arrears_agreement_status = tenancy['tenancy_details']['current_arrears_agreement_status']
          t.current_balance = tenancy['tenancy_details']['current_balance'].delete('¤').to_f
          t.primary_contact_name = tenancy['tenancy_details']['primary_contact_name']
          t.primary_contact_long_address = tenancy['tenancy_details']['primary_contact_long_address']
          t.primary_contact_postcode = tenancy['tenancy_details']['primary_contact_postcode']

          t.arrears_actions = extract_action_diary(events: tenancy['latest_action_diary_events'])
          t.agreements = extract_agreements(agreements: tenancy['latest_arrears_agreements'])
        end

        return Hackney::Income::Anonymizer.anonymize_tenancy(tenancy: tenancy_item) if Rails.env.staging?
        tenancy_item
      end

      def extract_action_diary(events:)
        events.map do |e|
          Hackney::Income::Domain::ActionDiaryEntry.new.tap do |t|
            t.balance = e['balance'].delete('¤').to_f
            t.code = e['code']
            t.type = e['type']
            t.date = e['date']
            t.comment = e['comment']
            t.universal_housing_username = e['universal_housing_username']
          end
        end
      end

      def extract_agreements(agreements:)
        agreements.map do |a|
          Hackney::Income::Domain::ArrearsAgreement.new.tap do |t|
            t.amount = a['amount'].delete('¤').to_f
            t.breached = a['breached']
            t.clear_by = a['clear_by']
            t.frequency = a['frequency']
            t.start_balance = a['start_balance']
            t.start_date = a['start_date']
            t.status = a['status']
          end
        end
      end
    end
  end
end
