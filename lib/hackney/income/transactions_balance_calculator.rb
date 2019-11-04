module Hackney
  module Income
    class TransactionsBalanceCalculator
      def organise_with_final_balances_by_week(current_balance:, transactions:)
        weeks_and_transactions = get_weeks(transactions, :timestamp)

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

      def combine_timeline(actions:, transactions:)
        weeks_and_actions = get_weeks(actions, :date)
        actions_summary = []
        weeks_and_actions.each do |week, actions_in_week|
          next unless actions_in_week.any?

          actions_summary << {
            week: week,
            actions: actions_in_week
          }
        end

        timeline = []
        transactions.each do |transaction_summary|
          summary_week = actions_summary.delete(
            actions_summary.detect { |t| t[:week] == transaction_summary[:week] }
          )
          timeline << transaction_summary.merge(summary_week) unless summary_week.nil?
        end

        actions_summary.each do |summary|
          timeline << {
            week: summary[:week],
            incoming: 0,
            outgoing: 0,
            summarised_transactions: [],
            actions: summary[:actions],
            final_balance: summary[:actions].first[:balance]&.delete('¤')
          }
        end

        timeline.sort_by { |k| k[:week].min }.reverse
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

      def get_weeks(transactions, time_field)
        return [] if transactions.empty?
        transactions.group_by { |t| t[time_field].all_week }
      end
    end
  end
end
