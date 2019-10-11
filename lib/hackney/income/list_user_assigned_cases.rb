module Hackney
  module Income
    class ListUserAssignedCases
      Response = Struct.new(:tenancies, :paused, :immediate_action, :full_patch, :upcoming_court_dates, :upcoming_evictions, :page_number, :number_of_pages)

      def initialize(tenancy_gateway:)
        @tenancy_gateway = tenancy_gateway
      end

      def execute(user_id:, page_number: nil, count_per_page: nil, paused: nil, immediate_action: nil, full_patch: nil, upcoming_court_dates: nil, upcoming_evictions: nil)
        get_tenancies_response = @tenancy_gateway.get_tenancies(
          user_id: user_id,
          page_number: page_number,
          number_per_page: count_per_page,
          paused: paused,
          full_patch: full_patch,
          upcoming_court_dates: upcoming_court_dates,
          upcoming_evictions: upcoming_evictions
        )

        Response.new(get_tenancies_response.tenancies, paused, page_number, get_tenancies_response.number_of_pages)
      end
    end
  end
end
