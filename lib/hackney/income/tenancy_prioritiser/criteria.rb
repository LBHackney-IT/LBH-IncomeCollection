module Hackney
  module Income
    class TenancyPrioritiser
      class Criteria
        def initialize(tenancy_attributes, transactions)
          @tenancy_attributes = tenancy_attributes
          @transactions = TransactionsBalanceCalculator.new.with_final_balances(
            current_balance: balance,
            transactions: transactions
          )
        end

        def balance
          tenancy_attributes.fetch(:current_balance).to_f
        end

        def broken_court_order?
          tenancy_attributes.fetch(:agreements).select { |a| a.fetch(:status) == 'breached' && a.fetch(:type) == 'court_ordered' }.any?
        end

        def days_in_arrears
          current_period_of_arrears = @transactions.take_while { |t| t.fetch(:final_balance).positive? }
          return 0 if current_period_of_arrears.empty?

          day_difference(Date.today, current_period_of_arrears.last.fetch(:timestamp))
        end

        def days_since_last_payment
          @transactions.empty? ? nil : day_difference(Date.today, @transactions.first.fetch(:timestamp))
        end

        def active_agreement?
          tenancy_attributes.fetch(:agreements).any? { |a| a.fetch(:status) == 'active' }
        end

        def nosp_served?
          tenancy_attributes.fetch(:arrears_actions).any? { |a| a.fetch(:type) == 'nosp' && within_last_year?(a.fetch(:date)) }
        end

        def active_nosp?
          tenancy_attributes.fetch(:arrears_actions).any? { |a| a.fetch(:type) == 'nosp' && within_last_month?(a.fetch(:date)) }
        end

        def number_of_broken_agreements
          tenancy_attributes.fetch(:agreements).select { |a| a.fetch(:status) == 'breached' }.count
        end

        def payment_amount_delta
          num_payments = @transactions.count
          return nil if num_payments < 3
          (@transactions.last.fetch(:value) - @transactions.fetch(num_payments - 2).fetch(:value)) -
            (@transactions.fetch(num_payments - 2).fetch(:value) - @transactions.fetch(num_payments - 3).fetch(:value))
        end

        def payment_date_delta
          num_payments = @transactions.count
          return nil if num_payments < 3
          day_difference(@transactions.last.fetch(:timestamp), @transactions.fetch(num_payments - 2).fetch(:timestamp)) - day_difference(@transactions.fetch(num_payments - 2).fetch(:timestamp), @transactions.fetch(num_payments - 3).fetch(:timestamp))
        end

        private

        attr_reader :tenancy_attributes, :transactions

        def within_last_year?(date)
          day_difference(Date.today, date) <= 365
        end

        def within_last_month?(date)
          day_difference(Date.today, date) <= 28
        end

        def day_difference(date_a, date_b)
          (date_a.to_date - date_b.to_date).to_i
        end
      end
    end
  end
end
