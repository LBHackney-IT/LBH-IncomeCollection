module Hackney
  module Income
    class GetAllDocuments
      def initialize(documents_gateway:)
        @documents_gateway = documents_gateway
      end

      def execute(filters: {})
        @documents_gateway.get_all(filters: filters)
      end
    end
  end
end
