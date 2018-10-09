module Hackney
  module Income
    class SearchTenanciesUsecase
      def initialize(search_gateway:)
        @search_gateway = search_gateway
      end

      def execute(search_term:, page: 0)
        @search_gateway.search(
          search_term: search_term,
          page: page,
          page_size: 10
        )
      end
    end
  end
end
