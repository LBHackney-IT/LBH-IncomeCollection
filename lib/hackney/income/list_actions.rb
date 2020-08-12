module Hackney
  module Income
    class ListActions
      Response = Struct.new(:actions, :paused, :page_number, :number_of_pages, :immediate_actions, :full_patch, :upcoming_court_dates, :upcoming_eviction)

      def initialize(actions_gateway:)
        @actions_gateway = actions_gateway
      end

      def execute(service_area_type:, filter_params:)
        filter_params.service_area_type = service_area_type
        get_actions_response = @actions_gateway.get_actions(filter_params: filter_params)

        Response.new(
          get_actions_response[:actions].map do |action|
            Income::Domain::LeaseholdActionListItem.new(action)
          end,
          filter_params.paused,
          filter_params.page_number,
          get_actions_response[:number_of_pages]
        )
      end
    end
  end
end
