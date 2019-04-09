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
      rescue Exceptions::IncomeApiError::NotFoundError
        Rails.logger.info("'#{self.class.name}' when trying to download_letter with id: '#{id}'")
        { status_code: 404 }
      end
    end
  end
end
