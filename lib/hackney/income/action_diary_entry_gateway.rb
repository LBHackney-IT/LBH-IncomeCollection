require 'uri'
require 'net/http'

module Hackney
  module Income
    class ActionDiaryEntryGateway
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def create_action_diary_entry(tenancy_ref:, balance:, code:, type:, date:, comment:, universal_housing_username:)
        body_data = {
          arrearsAction: {
            actionBalance: balance,
            actionCategory: '', # this is currently not used in the web service
            actionCode: code,
            comment: comment,
            confirmation: true,
            tenancyAgreementRef: tenancy_ref
          },
          # TODO: API should stop expecting these fields in future so they can be removed
          companyCode: '',
          directUser: {
            userName: '',
            userPassword: ''
          },
          masterPassword: '',
          sessionToken: '',
          sourceSystem: '',
          userId: 0
        }.to_json

        uri = URI.parse("#{@api_host}/tenancies/arrears-action-diary")
        req = Net::HTTP::Post.new(uri.path)
        req['Content-Type'] = 'application/json'
        req['X-Api-Key'] = @api_key

        Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req, body_data) }
      end

      def get_actions_for(tenancy_ref:)
        uri = URI.parse("#{@api_host}/tenancies/#{ERB::Util.url_encode(tenancy_ref)}/actions")
        req = Net::HTTP::Get.new(uri.path)
        req['Content-Type'] = 'application/json'
        req['X-Api-Key'] = @api_key

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }

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
