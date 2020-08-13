module Hackney
  module Income
    class ViewCourtCases
      def initialize(court_cases_gateway:)
        @court_cases_gateway = court_cases_gateway
      end

      def execute(tenancy_ref:)
        @court_cases_gateway.view_court_cases(
          tenancy_ref: tenancy_ref
        )
      end
    end
  end
end
