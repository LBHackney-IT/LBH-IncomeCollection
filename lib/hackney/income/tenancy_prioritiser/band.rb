module Hackney
  module Income
    class TenancyPrioritiser
      class Band
        def execute(criteria:)
          @criteria = criteria

          return :green if maintaining_agreement?
          return :red if red?
          return :amber if amber?
          :green
        end

        private

        def maintaining_agreement?
          # FIXME: may want to determine maintaining as more than just active in future
          @criteria.active_agreement?
        end

        def red?
          if @criteria.days_in_arrears.positive?
            return true if @criteria.days_in_arrears / 7 > 30
          end

          return true if @criteria.nosp_served? && @criteria.days_since_last_payment.nil? || @criteria.nosp_served? && @criteria.days_since_last_payment > 27

          return true if @criteria.balance > 1049

          return true if @criteria.broken_court_order?

          # the agreements data used here is assumed to be dated back 3 years at maximum
          return true if @criteria.number_of_broken_agreements > 2

          # positive delta = paid less than previous payment, negative delta = paid more
          return true if !@criteria.payment_amount_delta.nil? && @criteria.payment_amount_delta.positive?

          return false if @criteria.payment_date_delta.nil?

          @criteria.payment_date_delta > 3 || @criteria.payment_date_delta < -3
        end

        def amber?
          return true if @criteria.balance > 350

          return true if @criteria.days_in_arrears / 7 > 15

          return true if @criteria.nosp_served?

          return true if @criteria.number_of_broken_agreements.positive?
        end
      end
    end
  end
end
