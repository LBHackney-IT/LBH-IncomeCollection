module Hackney
  module Income
    module Domain
      class CourtCase
        include ActiveModel::Validations

        attr_accessor :id, :tenancy_ref, :court_date, :court_outcome, :balance_on_court_outcome_date, :strike_out_date,
                      :terms, :disrepair_counter_claim

        def expired?
          return false if strike_out_date.nil?

          strike_out_date.to_date <= Time.now
        end
      end
    end
  end
end
