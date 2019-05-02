module Hackney
  module Income
    class DocumentsGateway
      DOCUMENTS_ENDPOINT = 'v1/documents/'.freeze

      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def download_document(id:)
        res = make_request("#{@api_host}#{DOCUMENTS_ENDPOINT}#{id}/download", {})

        unless res.is_a? Net::HTTPSuccess
          raise Exceptions::IncomeApiError::NotFoundError.new(res), "when trying to download_letter with id: '#{id}'"
        end

        res
      end

      def get_all(filters: {})
        res = make_request("#{@api_host}#{DOCUMENTS_ENDPOINT}", filters)

        unless res.is_a? Net::HTTPSuccess
          raise Exceptions::IncomeApiError::NotFoundError.new(res), 'when trying to get all documents'
        end

        JSON.parse(res.body).map(&:deep_symbolize_keys).each do |doc|
          doc[:created_at] = Time.parse(doc[:created_at])
          doc[:updated_at] = Time.parse(doc[:updated_at])
          doc[:metadata] = JSON.parse(doc[:metadata] || '{}').deep_symbolize_keys
        end
      end

      private

      def make_request(url, query_params)
        uri = URI(url)
        uri.query = URI.encode_www_form(query_params)
        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key

        Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
      end
    end
  end
end
