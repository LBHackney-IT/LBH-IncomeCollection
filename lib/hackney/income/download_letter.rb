module Hackney
  module Income
    class DownloadLetter
      def initialize(letters_gateway:)
        @letters_gateway = letters_gateway
      end

      def execute(id:)
        @letters_gateway.download_letter(
          id: id
        )
      rescue Exceptions::IncomeApiError::NotFoundError
        Rails.logger.info("'#{self.class.name}' when trying to download_letter with id: '#{id}'")
        { status_code: 404 }
      end
    end
  end
end
