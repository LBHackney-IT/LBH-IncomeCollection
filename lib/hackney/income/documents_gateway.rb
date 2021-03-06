module Hackney
  module Income
    class DocumentsGateway
      DOCUMENTS_ENDPOINT = 'v1/documents/'.freeze

      def initialize(api_host:, api_key:)
        @api_host = api_host
        @api_key = api_key
      end

      def download_document(id:, username:, documents_view:)
        return unless username.present?

        res = make_request("#{@api_host}#{DOCUMENTS_ENDPOINT}#{id}/download", username: username, documents_view: documents_view)

        raise Exceptions::IncomeApiError::NotFoundError.new(res), "when trying to download_letter with id: '#{id}'" unless res.is_a? Net::HTTPSuccess

        res
      end

      def get_all(filters: {})
        res = make_request("#{@api_host}#{DOCUMENTS_ENDPOINT}", filters)

        raise Exceptions::IncomeApiError::NotFoundError.new(res), 'when trying to get all documents' unless res.is_a? Net::HTTPSuccess

        JSON.parse(res.body).deep_symbolize_keys
      end

      def review_failure(document_id:)
        uri = URI("#{@api_host}#{DOCUMENTS_ENDPOINT}#{document_id}/review_failure")
        req = Net::HTTP::Patch.new(uri)
        req['X-Api-Key'] = @api_key

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req) }

        raise Exceptions::IncomeApiError::NotFoundError.new(res), "when trying to mark document #{document_id} as reviewed" unless res.is_a? Net::HTTPSuccess

        res
      end

      private

      def make_request(url, query_params)
        uri = URI(url)
        uri.query = URI.encode_www_form(query_params)
        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key

        Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(req) }
      end
    end
  end
end
