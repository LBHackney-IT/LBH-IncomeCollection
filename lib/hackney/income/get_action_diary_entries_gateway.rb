require 'uri'
require 'net/http'

module Hackney
  module Income
    class GetActionDiaryEntriesGateway
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def get_actions_for(tenancy_ref:)
        uri = URI.parse("#{@api_host}/v1/tenancies/#{ERB::Util.url_encode(tenancy_ref)}/actions")
        req = Net::HTTP::Get.new(uri.path)
        req['Content-Type'] = 'application/json'
        req['X-Api-Key'] = @api_key

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }

        raise Exceptions::TenancyApiError.new(res), "when trying to get_tenancies for '#{tenancy_ref}'" unless res.is_a? Net::HTTPSuccess

        actions = JSON.parse(res.body)['arrears_action_diary_events']

        actions.map do |action|
          Hackney::Income::Domain::ActionDiaryEntry.new.tap do |t|
            t.balance = action['balance']
            t.code = action['code']
            t.type = action['type']
            t.date = action['date']
            t.comment = action['comment']
            t.universal_housing_username = action['universal_housing_username']
          end
        end
      end
    end
  end
end
