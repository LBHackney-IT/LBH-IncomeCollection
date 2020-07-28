module Hackney
  module Income
    class CreateCourtCase
      def initialize(court_cases_gateway:)
        @court_cases_gateway = court_cases_gateway
      end

      def execute(tenancy_ref:, court_decision_date:, court_outcome:, balance_at_outcome_date:, created_by:)
        @court_cases_gateway.create_court_case(
          tenancy_ref: tenancy_ref,
          court_decision_date: court_decision_date,
          court_outcome: court_outcome,
          balance_at_outcome_date: balance_at_outcome_date,
          created_by: created_by
        )
      end
    end
  end
end
