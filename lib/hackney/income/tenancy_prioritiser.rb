module Hackney
  module Income
    class TenancyPrioritiser
      def assign_priority_band(tenancy:, transactions:)
        @criteria = Hackney::Income::TenancyPrioritiser::Criteria.new(tenancy, transactions)

        tenancy[:priority_band] = 'Green'
        tenancy[:priority_band] = 'Amber' if amber?(tenancy)
        tenancy[:priority_band] = 'Red' if red?(tenancy)
      end

      private

      def amber?(tenancy)
        return true if @criteria.balance > 349

        return true if @criteria.days_in_arrears / 7 > 15

        return true if @criteria.nosp_served?

        return true if @criteria.number_of_broken_agreements.positive? && @criteria.active_agreement?

        false
      end

      def red?(tenancy)
        return true if @criteria.balance > 1049

        if @criteria.days_in_arrears.positive?
          return true if @criteria.days_in_arrears / 7 > 30
        end

        # positive delta = paid less than previous payment, negative delta = paid more
        return true if !@criteria.payment_amount_delta.nil? && @criteria.payment_amount_delta.positive?

        return true if @criteria.broken_court_order?

        return true if @criteria.number_of_broken_agreements > 2

        return true if @criteria.nosp_served? && @criteria.days_since_last_payment.nil? || @criteria.nosp_served? && @criteria.days_since_last_payment > 27

        return false if @criteria.payment_date_delta.nil?

        @criteria.payment_date_delta > 3 || @criteria.payment_date_delta < -3
      end
    end
  end
end

# the business rule is assumed to be >3 broken agreements in the last 3 years
# the agreements data used here is assumed to be dated back 3 years at maximum
