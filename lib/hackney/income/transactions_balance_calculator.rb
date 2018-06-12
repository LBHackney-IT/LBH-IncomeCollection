module Hackney
  module Income
    class TransactionsBalanceCalculator
      def with_final_balances(current_balance:, transactions:)
        desc_sort(transactions).reduce([]) do |final_transactions, transaction|
          final_balance = calculate_final_balance(final_transactions.last, current_balance)
          final_transactions + [transaction.merge(final_balance: final_balance)]
        end
      end

      private

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
