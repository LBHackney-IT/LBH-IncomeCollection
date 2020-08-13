module Hackney
  module Income
    module Domain
      class CourtCase
        include ActiveModel::Validations

        attr_accessor :id, :tenancy_ref, :court_date, :court_outcome, :balance_on_court_outcome_date, :strike_out_date,
                      :terms, :disrepair_counter_claim

        def start_date_display_date
          Date.parse(start_date).to_formatted_s(:long_ordinal)
        end
      end
    end
  end
end
