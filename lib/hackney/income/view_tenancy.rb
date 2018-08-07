require 'date'
require 'ostruct'

module Hackney
  module Income
    class ViewTenancy
      def initialize(tenancy_gateway:, transactions_gateway:, scheduler_gateway:, events_gateway:)
        @tenancy_gateway = tenancy_gateway
        @transactions_gateway = transactions_gateway
        @scheduler_gateway = scheduler_gateway
        @events_gateway = events_gateway
      end

      def execute(tenancy_ref:)
        tenancy = @tenancy_gateway.get_tenancy(tenancy_ref: tenancy_ref)
        transactions = @transactions_gateway.transactions_for(tenancy_ref: tenancy_ref)
        scheduled_actions = @scheduler_gateway.scheduled_jobs_for(tenancy_ref: tenancy_ref)
        events = @events_gateway.events_for(tenancy_ref: tenancy_ref)
        transactions_balance_calculator = Hackney::Income::TransactionsBalanceCalculator.new

        tenancy.transactions = transactions_balance_calculator.with_final_balances(
            current_balance: tenancy.current_balance.to_f,
            transactions: transactions.map do |transaction|
              {
                id: transaction.fetch(:id),
                timestamp: transaction.fetch(:timestamp),
                tenancy_ref: transaction.fetch(:tenancy_ref),
                description: transaction.fetch(:description),
                value: transaction.fetch(:value),
                type: transaction.fetch(:type)
              }
            end
          )

          tenancy.arrears_actions += events.map do |event|
            Hackney::Income::Domain::ActionDiaryEntry.new.tap do |t|
              t.balance = nil
              t.code = 'AUTO',
              t.type = event.fetch(:type)
              t.date = event.fetch(:timestamp)
              t.comment = event.fetch(:description)
              t.universal_housing_username = nil
            end
          end.reverse

        tenancy.scheduled_actions = scheduled_actions.map do |action|
          {
            scheduled_for: action.fetch(:scheduled_for),
            description: action.fetch(:description)
          }
        end

        tenancy
      end

      private

      def calculate_final_balance(next_transaction, current_balance)
        if next_transaction.present?
          next_transaction.fetch(:final_balance) - next_transaction.fetch(:value)
        else
          current_balance
        end
      end
    end
  end
end
