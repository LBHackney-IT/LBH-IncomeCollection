module Hackney
  module Income
    class TransactionsBalanceCalculator
      def with_final_balances(current_balance:, transactions:)
        desc_sort(transactions).reduce([]) do |final_transactions, transaction|
          final_balance = calculate_final_balance(final_transactions.last, current_balance)
          final_transactions + [transaction.merge(final_balance: final_balance)]
        end
      end

      def organise_with_final_balances(current_balance:, transactions:)
        weeks = get_weeks(transactions)
        return_result = []

        weeks.each do |week|
          transactions_in_week = transactions.select { |t| week.include?(t[:timestamp]) }
          return_result << {
            week: week,
            incoming: transactions_in_week.select { |v| v[:value].negative? }.sum { |v| v[:value] },
            outgoing: transactions_in_week.select { |v| v[:value].positive? }.sum { |v| v[:value] },
            summarised_transactions: transactions_in_week
          }
        end

        return_result.each_with_index do |result_week, i|
          if i == 0
            final_balance = current_balance
          else
            final_balance = return_result[i-1][:final_balance] - result_week[:outgoing] - result_week[:incoming]
          end
          result_week[:final_balance] = final_balance.round(2)
        end
        # byebug

        return_result
      end

      private

      def get_weeks(transactions)
        start_date = transactions.last[:timestamp]
        end_date = transactions.first[:timestamp]
        (start_date..end_date).group_by(&:all_week).map(&:first).reverse
      end

      def calculate_final_balance(next_transaction, current_balance)
        if next_transaction.present?
          next_transaction.fetch(:final_balance) - next_transaction.fetch(:value)
        else
          current_balance
        end
      end

      def desc_sort(transactions)
        transactions.sort_by { |t| t.fetch(:timestamp) }.reverse
      end
    end
  end
end
