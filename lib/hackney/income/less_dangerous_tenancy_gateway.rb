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
          t.current_balance = tenancy['current_balance']
          t.current_arrears_agreement_status = tenancy['current_arrears_agreement_status']
          t.latest_action_code = tenancy['latest_action']['code']
          t.latest_action_date = tenancy['latest_action']['date']
          t.primary_contact_name = tenancy['primary_contact']['name']
          t.primary_contact_short_address = tenancy['primary_contact']['short_address']
          t.primary_contact_postcode = tenancy['primary_contact']['postcode']
          t
        end
      end

      def convert_to_params_array(refs:)
        RestClient::ParamsArray.new(refs.map.with_index(0) { |e, i| [i, e] }.to_a)
      end

      def get_tenancy(tenancy_ref:)
        response = RestClient.get(
          "#{@api_host}/tenancies/#{tenancy_ref}",
          'x-api-key' => @api_key
        )
        tenancy = JSON.parse(response.body)

        Hackney::Income::Domain::Tenancy.new.tap do |t|
          t.ref = tenancy['tenancy_details']['ref']
          t.current_arrears_agreement_status = tenancy['tenancy_details']['current_arrears_agreement_status']
          t.primary_contact_name = tenancy['tenancy_details']['primary_contact_name']
          t.primary_contact_long_address = tenancy['tenancy_details']['primary_contact_long_address']
          t.primary_contact_postcode = tenancy['tenancy_details']['primary_contact_postcode']

          t.arrears_actions = extract_action_diary(events: tenancy['latest_action_diary_events'])
          t.agreements = extract_agreements(agreements: tenancy['latest_arrears_agreements'])
        end
      end

      def extract_action_diary(events:)
        events.map do |e|
          Hackney::Income::Domain::ActionDiaryEntry.new.tap do |t|
            t.balance = e['balance']
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
            t.amount = a['amount']
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