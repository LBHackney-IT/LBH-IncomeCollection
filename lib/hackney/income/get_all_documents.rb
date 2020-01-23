module Hackney
  module Income
    class GetAllDocuments
      def initialize(documents_gateway:)
        @documents_gateway = documents_gateway
      end

      def execute(filters: {})
        response = @documents_gateway.get_all(filters: filters)

        response[:documents] = response[:documents].each do |doc|
          doc[:created_at] = Time.zone.parse(doc[:created_at])
          doc[:updated_at] = Time.zone.parse(doc[:updated_at])
          doc[:metadata] = JSON.parse(doc[:metadata] || '{}').deep_symbolize_keys
        end

        response
      end
    end
  end
end
