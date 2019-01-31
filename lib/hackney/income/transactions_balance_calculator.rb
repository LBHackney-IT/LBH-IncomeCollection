module Hackney
  module Income
    class TransactionsBalanceCalculator
      def organise_with_final_balances_by_week(current_balance:, transactions:)
        weeks = get_weeks(transactions)
        transactions_summary = []

        weeks.each do |week|
          transactions_in_week = get_transactions_by_week(transactions, week)
          incoming_sum = get_incoming_sum(transactions_in_week)
          outgoing_sum = get_outgoing_sum(transactions_in_week)

          transactions_summary << {
            week: week,
            incoming: incoming_sum,
            outgoing: outgoing_sum,
            summarised_transactions: transactions_in_week,
            final_balance: weekly_balance(current_balance, incoming_sum, outgoing_sum, transactions_summary)
          }
        end

        transactions_summary
      end

      private

      def weekly_balance(current_balance, weekly_incoming_sum, weekly_outgoing_sum, transactions_summary)
        if transactions_summary.empty?
          current_balance
        else
          transactions_summary.last[:final_balance] + weekly_incoming_sum.abs - weekly_outgoing_sum.abs
        end
      end

      def get_transactions_by_week(transactions, week)
        transactions.select { |t| week.include?(t[:timestamp]) }
      end

      def get_outgoing_sum(transactions_in_week)
        transactions_in_week.select { |v| v[:value].positive? }.sum { |v| v[:value] }
      end

      def get_incoming_sum(transactions_in_week)
        transactions_in_week.select { |v| v[:value].negative? }.sum { |v| v[:value] }
      end

      def get_weeks(transactions)
        return [] if transactions.empty?
        start_date = transactions.last[:timestamp]
        end_date = transactions.first[:timestamp]
        (start_date..end_date).group_by(&:all_week).map(&:first).reverse
      end
    end
  end
end
