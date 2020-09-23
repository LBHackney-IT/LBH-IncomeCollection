module Hackney
  module Income
    class UpdateCourtCase
      def initialize(court_cases_gateway:)
        @court_cases_gateway = court_cases_gateway
      end

      def execute(court_case_params:)
        court_case_params = {
          id: court_case_params[:id],
          court_date: court_case_params[:court_date],
          court_outcome: court_case_params[:court_outcome],
          balance_on_court_outcome_date: court_case_params[:balance_on_court_outcome_date],
          strike_out_date: court_case_params[:strike_out_date],
          terms: court_case_params[:terms],
          disrepair_counter_claim: court_case_params[:disrepair_counter_claim],
          username: court_case_params[:username]
        }

        @court_cases_gateway.update_court_case(court_case_params: court_case_params)
      end
    end
  end
end
