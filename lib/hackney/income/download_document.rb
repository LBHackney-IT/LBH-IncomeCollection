module Hackney
  module Income
    class DownloadDocument
      def initialize(documents_gateway:)
        @documents_gateway = documents_gateway
      end

      def execute(id:)
        @documents_gateway.download_document(
          id: id
        )
      end
    end
  end
end
