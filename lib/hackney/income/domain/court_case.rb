module Hackney
  module Income
    module Domain
      class CourtCase
        class CourtOutcomeCodes
          ADJOURNED_ON_TERMS = 'ADT'.freeze
          ADJOURNED_GENERALLY_WITH_PERMISSION_TO_RESTORE = 'AGP'.freeze
          ADJOURNED_TO_NEXT_OPEN_DATE = 'AND'.freeze
          ADJOURNED_TO_ANOTHER_HEARING_DATE = 'AAH'.freeze
          ADJOURNED_FOR_DIRECTIONS_HEARING = 'ADH'.freeze

          OUTRIGHT_POSSESSION_WITH_DATE = 'OPD'.freeze
          OUTRIGHT_POSSESSION_FORTHWITH = 'OPF'.freeze

          SUSPENSION_ON_TERMS = 'SOT'.freeze
          STRUCK_OUT = 'STO'.freeze
          WITHDRAWN_ON_THE_DAY = 'WIT'.freeze

          STAY_OF_EXECUTION = 'SOE'.freeze
        end

        include ActiveModel::Validations

        attr_accessor :id, :tenancy_ref, :court_date, :court_outcome, :balance_on_court_outcome_date, :strike_out_date,
                      :terms, :disrepair_counter_claim

        def initialize(attributes = {})
          @court_outcome = attributes[:court_outcome]
        end

        def result_in_agreement?
          terms.present? && !expired?
        end

        def expired?
          return true if struck_out?
          return true if end_of_life?

          false
        end

        def can_have_terms?
          [
            CourtOutcomeCodes::ADJOURNED_ON_TERMS,
            CourtOutcomeCodes::ADJOURNED_GENERALLY_WITH_PERMISSION_TO_RESTORE,
            CourtOutcomeCodes::ADJOURNED_TO_NEXT_OPEN_DATE,
            CourtOutcomeCodes::ADJOURNED_TO_ANOTHER_HEARING_DATE,
            CourtOutcomeCodes::ADJOURNED_FOR_DIRECTIONS_HEARING,
            CourtOutcomeCodes::SUSPENSION_ON_TERMS,
            CourtOutcomeCodes::STAY_OF_EXECUTION
          ].include?(court_outcome)
        end

        def future?
          return false if court_date.nil?

          court_date.to_datetime.future?
        end

        private

        def struck_out?
          strike_out_date.present? && strike_out_date.to_date <= Date.today
        end

        def end_of_life?
          return false if court_date.nil?

          court_outcome == CourtOutcomeCodes::SUSPENSION_ON_TERMS && court_date.to_date + 6.years <= Date.today
        end
      end
    end
  end
end
