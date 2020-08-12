module Hackney
  module Income
    class Timeline
      class << self
        def build(tenancy_ref:, current_balance:, actions:, transactions:)
          new.execute(
            tenancy_ref: tenancy_ref,
            current_balance: current_balance,
            actions: actions,
            transactions: transactions
          )
        end
      end

      def execute(tenancy_ref:, current_balance:, actions:, transactions:)
        @tenancy_ref = tenancy_ref
        timeline_list = combine_actions_and_transactions(actions, transactions)
        timeline_list = calculate_balances(current_balance, timeline_list)

        create_weekly_summaries(timeline_list, current_balance)
          .sort_by { |date_key, _summary| date_key }
          .reverse
      end

      private

      def create_weekly_summaries(timeline_list, current_balance)
        prev_week_summary_group = nil

        grouped_timeline_by_year_and_week = timeline_list.group_by { |item| item[:date].strftime('%Y-%W') }

        grouped_timeline_by_year_and_week.reduce({}) do |groups, (date_key, week_group)|
          beginning_of_week = week_group.first[:date].beginning_of_week
          end_of_week       = beginning_of_week.end_of_week

          current_week_summary_group = {
            list: week_group,
            date_range: beginning_of_week..end_of_week,
            balance: (start_of_previous_week_balance(prev_week_summary_group) || current_balance),
            incoming: week_group.select { |item| item[:value].negative? }.sum { |item| item[:value] },
            outgoing: week_group.select { |item| item[:value].positive? }.sum { |item| item[:value] },
            num_of_actions: week_group.count { |item| item[:action] },
            num_of_transactions: week_group.count { |item| item[:transaction] }
          }

          groups[date_key] = current_week_summary_group

          prev_week_summary_group = current_week_summary_group

          groups
        end
      end

      def start_of_previous_week_balance(prev_week_summary_group)
        return nil if prev_week_summary_group.nil?

        prev_week_summary_group[:list].last[:balance]
      end

      def calculate_balances(current_balance, timeline_list)
        prev_balance = current_balance

        timeline_list.sort_by { |item| [item[:date], item[:comment]] }.reverse.map do |item|
          calculated_balance = prev_balance - item[:value]

          prev_balance = calculated_balance

          item[:balance] = calculated_balance

          item
        end
      end

      def combine_actions_and_transactions(actions, transactions)
        timeline_list = []

        transactions.each do |transaction|
          timeline_list << {
            date: transaction[:timestamp],
            code: nil,
            balance: 0,
            type: transaction[:type],
            comment: transaction[:description],
            value: transaction[:value],
            user: nil,
            transaction: true,
            action: false
          }
        end

        actions.each do |action|
          action_diary_balance = BigDecimal(action[:balance].to_s.gsub(/[¤\),]/, '').tr('(', '-')) if action[:balance].present?

          timeline_list << {
            date: action[:date],
            code: action[:code],
            balance: 0,
            action_diary_balance: action_diary_balance,
            comment: action[:comment].nil? ? '' : action[:comment],
            value: 0,
            user: action[:universal_housing_username],
            transaction: false,
            action: true
          }
        end

        timeline_list
      end
    end
  end
end
