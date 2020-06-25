module Hackney
  module Income
    module Domain
      class Agreement
        include ActiveModel::Validations

        attr_accessor :id, :tenancy_ref, :agreement_type, :starting_balance, :amount, :frequency,
                      :start_date, :current_state, :history

        def start_date_display_date
          Date.parse(start_date).to_formatted_s(:long_ordinal)
        end
      end
    end
  end
end
