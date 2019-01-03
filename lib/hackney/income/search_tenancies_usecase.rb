module Hackney
  module Income
    class SearchTenanciesUsecase
      def initialize(search_gateway:)
        @search_gateway = search_gateway
      end

      def execute(search_term:, page: 1, first_name: '', last_name: '', address: '', post_code: '', tenancy_ref: '')
        page = [page, 1].max
        res = if search_term
                @search_gateway.search(
                  search_term: search_term,
                  page: page,
                  page_size: 10,
                  first_name: first_name,
                  last_name: last_name,
                  address: address,
                  post_code: post_code,
                  tenancy_ref: tenancy_ref
                )
              else
                { tenancies: [], number_of_pages: 0, number_of_results: 0 }
              end
        res[:search_term] = search_term
        res[:page] = page
        res
      end
    end
  end
end
