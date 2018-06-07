module Hackney
  module Income
    class TenancyPrioritiser
      def assign_priority_band(tenancy:, transactions:)
        @criteria = Hackney::Income::TenancyPrioritiser::Criteria.new(tenancy, transactions)
        tenancy[:priority_band] = 'Red' if is_red?(tenancy)
      end

      private
      def is_red?(tenancy)
        return true if @criteria.balance > 1049

        return true if @criteria.payment_amount_delta != nil && @criteria.payment_amount_delta < 0

        return true if @criteria.broken_court_order?

        return true if @criteria.number_of_broken_agreements > 2

        return true if @criteria.nosp_served? && @criteria.days_since_last_payment == nil || @criteria.nosp_served? && @criteria.days_since_last_payment > 27

        if @criteria.payment_date_delta != nil
          return @criteria.payment_date_delta > 3 || @criteria.payment_date_delta < -3
        end
      end
    end
  end
end


# the business rule is assumed to be >3 broken agreements in the last 3 years
# the agreements data used here is assumed to be dated back 3 years at maximum
