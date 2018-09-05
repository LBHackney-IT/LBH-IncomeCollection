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
            actionBalance: balance.to_f,
            actionCategory: '',
            actionCode: code,
            comment: comment,
            confirmation: true,
            tenancyAgreementRef: tenancy_ref
          },
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
        req['x-api-key'] = @api_key

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req, body_data) }
      end
    end
  end
end
