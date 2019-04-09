module Hackney
  module Income
    class DocumentsGateway
      DOCUMENT_ENDPOINT = 'v1/documents/'.freeze

      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def download_document(id:)
        uri = URI("#{@api_host}#{DOCUMENT_ENDPOINT}#{id}/download")

        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key
        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

        unless res.is_a? Net::HTTPSuccess
          raise Exceptions::IncomeApiError::NotFoundError.new(res), "when trying to download_letter with id: '#{id}'"
        end

        res
      end

    end
  end
end
