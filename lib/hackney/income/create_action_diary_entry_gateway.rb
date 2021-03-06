require 'uri'
require 'net/http'

module Hackney
  module Income
    class CreateActionDiaryEntryGateway
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def create_action_diary_entry(username:, tenancy_ref:, action_code:, comment:)
        body_data = {
          action_code: action_code,
          comment: comment,
          username: username
        }.to_json

        uri = URI.parse("#{@api_host}/v1/tenancies/#{ERB::Util.url_encode(tenancy_ref)}/action_diary")
        req = Net::HTTP::Post.new(uri.path)
        req['Content-Type'] = 'application/json'
        req['X-Api-Key'] = @api_key

        responce = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req, body_data) }

        raise Exceptions::IncomeApiError.new(responce), "when trying to create_action_diary_entry using '#{uri}'" unless responce.is_a? Net::HTTPSuccess

        responce.body
      end
    end
  end
end
