module Hackney
  module Income
    class DownloadDocument
      def initialize(documents_gateway:)
        @documents_gateway = documents_gateway
      end

      def execute(id:, username:, documents_view:)
        @documents_gateway.download_document(
          id: id,
          username: username,
          documents_view: documents_view
        )
      end
    end
  end
end
