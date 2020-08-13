module Hackney
  module Income
    module Domain
      class CourtCase
        include ActiveModel::Validations

        attr_accessor :id, :tenancy_ref, :court_date, :court_outcome, :balance_on_court_outcome_date, :strike_out_date,
                      :terms, :disrepair_counter_claim
      end
    end
  end
end
