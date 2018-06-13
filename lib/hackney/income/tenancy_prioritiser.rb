module Hackney
  module Income
    class TenancyPrioritiser
      def initialize(tenancy:, transactions:)
        @criteria = Hackney::Income::TenancyPrioritiser::Criteria.new(tenancy, transactions)
      end

      def priority_band
        return :red if red?
        return :amber if amber?
        :green
      end

      private

      def amber?
        return true if @criteria.balance > 349

        return true if @criteria.days_in_arrears / 7 > 15

        return true if @criteria.nosp_served?

        return true if @criteria.number_of_broken_agreements.positive? && @criteria.active_agreement?

        false
      end

      def red?
        return true if @criteria.balance > 1049

        if @criteria.days_in_arrears.positive?
          return true if @criteria.days_in_arrears / 7 > 30
        end

        # positive delta = paid less than previous payment, negative delta = paid more
        return true if !@criteria.payment_amount_delta.nil? && @criteria.payment_amount_delta.positive?

        return true if @criteria.broken_court_order?

        # the business rule is assumed to be >3 broken agreements in the last 3 years
        # the agreements data used here is assumed to be dated back 3 years at maximum
        return true if @criteria.number_of_broken_agreements > 2

        return true if @criteria.nosp_served? && @criteria.days_since_last_payment.nil? || @criteria.nosp_served? && @criteria.days_since_last_payment > 27

        return false if @criteria.payment_date_delta.nil?

        @criteria.payment_date_delta > 3 || @criteria.payment_date_delta < -3
      end
    end
  end
end
