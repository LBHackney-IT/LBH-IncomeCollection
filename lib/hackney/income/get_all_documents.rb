module Hackney
  module Income
    class GetAllDocuments
      def initialize(documents_gateway:)
        @documents_gateway = documents_gateway
      end

      def execute(filters: {})
        response = @documents_gateway.get_all(filters: filters)

        response[:documents] = response[:documents].map(&:deep_symbolize_keys).each do |doc|
          doc[:created_at] = doc[:created_at].to_time
          doc[:updated_at] = doc[:updated_at].to_time
          doc[:metadata] = JSON.parse(doc[:metadata] || '{}').deep_symbolize_keys
        end

        response
      end
    end
  end
end
