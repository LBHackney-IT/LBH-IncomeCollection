module Hackney
  module Income
    class RegisterUsersGateway
      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def find_or_create_user(provider_uid:, provider:, name:, email:, first_name:, last_name:, provider_permissions:)
        uri = URI("#{@api_host}/users/find-or-create")
        params = {
          provider_uid: provider_uid,
          provider: provider,
          name: name,
          email: email,
          first_name: first_name,
          last_name: last_name,
          provider_permissions: provider_permissions
        }
        uri.query = URI.encode_www_form(params)

        req = Net::HTTP::Post.new(uri)
        req['X-Api-Key'] = @api_key

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
        body = JSON.parse(res.body)

        {
          id: body['id'],
          name: body['name'],
          email: body['email'],
          first_name: body['first_name'],
          last_name: body['last_name'],
          provider_permissions: body['provider_permissions']
        }
      end
    end
  end
end
