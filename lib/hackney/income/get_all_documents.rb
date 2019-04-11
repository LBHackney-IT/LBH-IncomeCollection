module Hackney
  module Income
    class GetAllDocuments
      def initialize(documents_gateway:)
        @documents_gateway = documents_gateway
      end

      def execute
        @documents_gateway.get_all
      end
    end
  end
end
