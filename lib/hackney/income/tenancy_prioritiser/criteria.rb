module Hackney
  module Income
    class TenancyPrioritiser
      class Criteria
        def initialize(tenancy_attributes, transactions)
          @tenancy_attributes = tenancy_attributes
          @transactions = transactions
        end

        def balance
          tenancy_attributes.fetch(:current_balance).to_f
        end

        def days_since_last_payment
          day_difference(Date.today, @transactions.first.fetch(:timestamp))
        end

        def number_of_broken_agreements
          tenancy_attributes.fetch(:agreements).select { |a| a.fetch(:status) == 'breached' }.count
        end

        def broken_court_order?
          tenancy_attributes.fetch(:agreements).select { |a| a.fetch(:status) == 'breached' && a.fetch(:type) == 'court_ordered' }.any?
        end

        def nosp_served?
          tenancy_attributes.fetch(:arrears_actions).any? { |a| a.fetch(:type) == 'nosp' && within_last_year?(a.fetch(:date))  }
        end

        private

        attr_reader :tenancy_attributes

        def within_last_year?(date)
          day_difference(Date.today, date) <= 365
        end

        def day_difference(date_a, date_b)
          (date_a.to_date - date_b.to_date).to_i
        end
      end
    end
  end
end
