module Hackney
  module Income
    class LessDangerousTenancyGateway
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def get_tenancies_list(refs:)
        response = RestClient.get("#{@api_host}/tenancies",
          { 'x-api-key' => @api_key,
            :params=> { :tenancy_refs => convert_to_params_array(refs: refs) }
          }
        )
        tenancies = JSON.parse(response.body)['tenancies']

        tenancy_list = tenancies.map do |tenancy|
          t = Hackney::Income::Types::TenancyListItem.new()
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
    end
  end
end
