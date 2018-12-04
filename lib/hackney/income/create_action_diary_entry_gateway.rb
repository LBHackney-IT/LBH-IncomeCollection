require 'uri'
require 'net/http'

module Hackney
  module Income
    class CreateActionDiaryEntryGateway
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def create_action_diary_entry(user_id:, tenancy_ref:, action_code:, comment:)
        body_data = {
          action_code: action_code,
          comment: comment,
          user_id: user_id
        }.to_json

        uri = URI.parse("#{@api_host}/tenancies/#{ERB::Util.url_encode(tenancy_ref)}/action_diary")
        req = Net::HTTP::Post.new(uri.path)
        req['Content-Type'] = 'application/json'
        req['X-Api-Key'] = @api_key

        responce = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req, body_data) }

        unless responce.is_a? Net::HTTPSuccess
          raise Exceptions::IncomeApiError.new(responce), "when trying to create_action_diary_entry using '#{uri}'"
        end
        responce.body
      end
    end
  end
end
