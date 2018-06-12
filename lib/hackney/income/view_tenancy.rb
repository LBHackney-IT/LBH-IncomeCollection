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

        Hackney::Tenancy.new.tap do |t|
          t.ref = tenancy.fetch(:ref)
          t.current_balance = tenancy.fetch(:current_balance)
          t.type = tenancy.fetch(:type)
          t.start_date = Date.parse(tenancy.fetch(:start_date))

          t.primary_contact = {
            first_name: tenancy.dig(:primary_contact, :first_name),
            last_name: tenancy.dig(:primary_contact, :last_name),
            title: tenancy.dig(:primary_contact, :title),
            contact_number: tenancy.dig(:primary_contact, :contact_number),
            email_address: tenancy.dig(:primary_contact, :email_address)
          }

          t.address = {
            address_1: tenancy.dig(:address, :address_1),
            address_2: tenancy.dig(:address, :address_2),
            address_3: tenancy.dig(:address, :address_3),
            address_4: tenancy.dig(:address, :address_4),
            post_code: tenancy.dig(:address, :post_code)
          }

          t.agreements = tenancy.fetch(:agreements).map do |agreement|
            {
              status: agreement.fetch(:status),
              type: agreement.fetch(:type),
              value: agreement.fetch(:value),
              frequency: agreement.fetch(:frequency),
              created_date: Date.parse(agreement.fetch(:created_date))
            }
          end

          t.arrears_actions = tenancy.fetch(:arrears_actions).map do |action|
            {
              type: action.fetch(:type),
              automated: action.fetch(:automated),
              user: { name: action.dig(:user, :name) },
              date: Date.parse(action.fetch(:date)),
              description: action.fetch(:description)
            }
          end

          t.arrears_actions += events.map do |event|
            {
              type: event.fetch(:type),
              automated: event.fetch(:automated),
              user: nil,
              date: event.fetch(:timestamp),
              description: event.fetch(:description)
            }
          end

          t.arrears_actions
            .sort_by! { |event| event.fetch(:date) }
            .reverse!

          t.scheduled_actions = scheduled_actions.map do |action|
            {
              scheduled_for: action.fetch(:scheduled_for),
              description: action.fetch(:description)
            }
          end

          t.transactions = transactions_balance_calculator.with_final_balances(
            current_balance: tenancy.fetch(:current_balance).to_f,
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
    end
  end
end
