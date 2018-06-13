module Hackney
  module Income
    class TenancyPrioritiser
      class StubCriteria
        attr_accessor :balance, :broken_court_order, :days_in_arrears,
          :number_of_broken_agreements, :nosp_served, :days_since_last_payment,
          :payment_date_delta, :payment_amount_delta, :active_agreement, :active_nosp

        def balance
          @balance || 100.00
        end

        def broken_court_order?
          @broken_court_order || false
        end

        def days_in_arrears
          @days_in_arrears || 7
        end

        def days_since_last_payment
          @days_since_last_payment
        end

        def active_agreement?
          @active_agreement || false
        end

        def nosp_served?
          @nosp_served || false
        end

        def active_nosp?
          @active_nosp || false
        end

        def number_of_broken_agreements
          @number_of_broken_agreements || 0
        end

        def payment_amount_delta
          @payment_amount_delta || 0
        end

        def payment_date_delta
          @payment_date_delta || 0
        end

      end
    end
  end
end
