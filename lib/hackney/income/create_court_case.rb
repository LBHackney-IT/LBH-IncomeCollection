module Hackney
  module Income
    class CreateCourtCase
      def initialize(court_cases_gateway:)
        @court_cases_gateway = court_cases_gateway
      end

      def execute(tenancy_ref:, date_of_court_decision:, court_outcome:, balance_on_court_outcome_date:, strike_out_date:, created_by:)
        @court_cases_gateway.create_court_case(
          tenancy_ref: tenancy_ref,
          date_of_court_decision: date_of_court_decision,
          court_outcome: court_outcome,
          balance_on_court_outcome_date: balance_on_court_outcome_date,
          strike_out_date: strike_out_date,
          created_by: created_by
        )
      end
    end
  end
end
