module Hackney
  module Income
    class ListCases
      Response = Struct.new(:tenancies, :paused, :page_number, :number_of_pages, :immediate_actions, :full_patch, :upcoming_court_dates, :upcoming_eviction)

      def initialize(tenancy_gateway:)
        @tenancy_gateway = tenancy_gateway
      end

      def execute(filter_params:)
        get_tenancies_response = @tenancy_gateway.get_tenancies(filter_params: filter_params)

        Response.new(
          get_tenancies_response.tenancies,
          filter_params.paused,
          filter_params.page_number,
          get_tenancies_response.number_of_pages
        )
      end
    end
  end
end
