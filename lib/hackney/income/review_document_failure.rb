module Hackney
  module Income
    class ReviewDocumentFailure
      def initialize(documents_gateway:)
        @documents_gateway = documents_gateway
      end

      def execute(document_id:)
        @documents_gateway.review_failure(document_id: document_id)
      end
    end
  end
end
