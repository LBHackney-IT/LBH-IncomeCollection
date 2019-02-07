module Hackney
  module Income
    class TransactionsBalanceCalculator
      def organise_with_final_balances_by_week(current_balance:, transactions:)
        weeks_and_transactions = get_weeks(transactions)

        transactions_summary = []

        weeks_and_transactions.each do |week, transactions_in_week|
          next unless transactions_in_week.any?

          transactions_summary << {
            week: week,
            incoming: get_incoming_sum(transactions_in_week),
            outgoing: get_outgoing_sum(transactions_in_week),
            summarised_transactions: transactions_in_week,
            final_balance: weekly_balance(current_balance, transactions_summary)
          }
        end

        transactions_summary
      end

      private

      def weekly_balance(current_balance, transactions_summary)
        if transactions_summary.empty?
          current_balance
        else
          transactions_summary.last[:final_balance] + transactions_summary.last[:incoming].abs - transactions_summary.last[:outgoing].abs
        end
      end

      def get_outgoing_sum(transactions_in_week)
        transactions_in_week.select { |v| v[:value].positive? }.sum { |v| v[:value] }
      end

      def get_incoming_sum(transactions_in_week)
        transactions_in_week.select { |v| v[:value].negative? }.sum { |v| v[:value] }
      end

      def get_weeks(transactions)
        return [] if transactions.empty?
        transactions.group_by { |t| t[:timestamp].all_week }
      end
    end
  end
end
