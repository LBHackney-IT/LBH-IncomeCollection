module Hackney
  module Income
    class ListUserAssignedCases
      Response = Struct.new(:tenancies, :paused, :page_number, :number_of_pages)

      def initialize(tenancy_gateway:)
        @tenancy_gateway = tenancy_gateway
      end

      def execute(user_id:, page_number: nil, count_per_page: nil, paused: nil)
        get_tenancies_response = @tenancy_gateway.get_tenancies(
          user_id: user_id,
          page_number: page_number,
          number_per_page: count_per_page,
          paused: paused
        )

        Response.new(get_tenancies_response.tenancies, paused, page_number, get_tenancies_response.number_of_pages)
      end
    end
  end
end
