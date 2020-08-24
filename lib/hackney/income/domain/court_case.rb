module Hackney
  module Income
    module Domain
      class CourtCase
        class CourtOutcomeCodes
          ADJOURNED_GENERALLY_WITH_PERMISSION_TO_RESTORE = 'AGP'.freeze
          ADJOURNED_TO_NEXT_OPEN_DATE = 'AND'.freeze
          ADJOURNED_TO_ANOTHER_HEARING_DATE = 'AAH'.freeze
          ADJOURNED_FOR_DIRECTIONS_HEARING = 'ADH'.freeze

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

        def expired?
          return true if struck_out?
          return true if end_of_life?

          false
        end

        def adjourned?
          [
            CourtOutcomeCodes::ADJOURNED_GENERALLY_WITH_PERMISSION_TO_RESTORE,
            CourtOutcomeCodes::ADJOURNED_TO_NEXT_OPEN_DATE,
            CourtOutcomeCodes::ADJOURNED_TO_ANOTHER_HEARING_DATE,
            CourtOutcomeCodes::ADJOURNED_FOR_DIRECTIONS_HEARING
          ].include?(court_outcome)
        end

        private

        def struck_out?
          strike_out_date.present? && strike_out_date.to_date <= Date.today
        end

        def end_of_life?
          court_outcome == CourtOutcomeCodes::SUSPENSION_ON_TERMS && court_date.to_date + 6.years <= Date.today
        end
      end
    end
  end
end
