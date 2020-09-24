module Hackney
  module Income
    class CreateCourtCase
      def initialize(court_cases_gateway:)
        @court_cases_gateway = court_cases_gateway
      end

      def execute(create_court_case_params:)
        create_court_case_params = {
          tenancy_ref: create_court_case_params[:tenancy_ref],
          court_date: create_court_case_params[:court_date],
          court_outcome: create_court_case_params[:court_outcome],
          balance_on_court_outcome_date: create_court_case_params[:balance_on_court_outcome_date],
          strike_out_date: create_court_case_params[:strike_out_date],
          terms: create_court_case_params[:terms],
          disrepair_counter_claim: create_court_case_params[:disrepair_counter_claim],
          username: create_court_case_params[:username]
        }

        @court_cases_gateway.create_court_case(create_court_case_params: create_court_case_params)
      end
    end
  end
end
