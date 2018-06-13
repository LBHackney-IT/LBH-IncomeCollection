module Hackney
  module Income
    class TenancyPrioritiser
      class PriorityWeightings
        attr_writer :balance, :days_in_arrears, :days_since_last_payment,
                    :payment_amount_delta, :payment_date_delta, :number_of_broken_agreements,
                    :active_agreement, :broken_court_order, :nosp_served, :active_nosp

        def balance
          @balance || 1.2
        end

        def days_in_arrears
          @days_in_arrears || 1.5
        end

        def days_since_last_payment
          @days_since_last_payment || 1
        end

        def payment_amount_delta
          @payment_amount_delta || 1
        end

        def payment_date_delta
          @payment_date_delta || 5
        end

        def number_of_broken_agreements
          @number_of_broken_agreements || 50
        end

        def active_agreement
          @active_agreement || 100
        end

        def broken_court_order
          @broken_court_order || 200
        end

        def nosp_served
          @nosp_served || 20
        end

        def active_nosp
          @active_nosp || 50
        end
      end
    end
  end
end
