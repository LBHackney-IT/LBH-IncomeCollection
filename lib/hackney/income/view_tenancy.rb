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

        tenancy.contacts = @tenancy_gateway.get_contacts_for(tenancy_ref: tenancy_ref).map do |contact|
          {
            contact_id: contact.contact_id,
            email_address: contact.email_address,
            uprn: contact.uprn,
            address_line_1: contact.address_line_1,
            address_line_2: contact.address_line_2,
            address_line_3: contact.address_line_3,
            first_name: contact.first_name,
            last_name: contact.last_name,
            full_name: contact.full_name,
            larn: contact.larn,
            telephone_1: contact.telephone_1,
            telephone_2: contact.telephone_2,
            telephone_3: contact.telephone_3,
            cautionary_alert: contact.cautionary_alert,
            property_cautionary_alert: contact.property_cautionary_alert,
            house_ref: contact.house_ref,
            title: contact.title,
            full_address_display: contact.full_address_display,
            full_address_search: contact.full_address_search,
            post_code: contact.post_code,
            date_of_birth: contact.date_of_birth,
            hackney_homes_id: contact.hackney_homes_id
          }
        end

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

        tenancy.transactions = transaction_date_summary(tenancy.transactions)

        tenancy.arrears_actions += events.map do |event|
          Hackney::Income::Domain::ActionDiaryEntry.new.tap do |t|
            t.balance = nil
            t.code = 'AUTO'
            t.type = event.fetch(:type)
            t.date = event.fetch(:timestamp).to_s
            t.comment = event.fetch(:description)
            t.universal_housing_username = nil
          end
        end.reverse

        tenancy.arrears_actions = tenancy.arrears_actions.map do |event|
          {
            balance: event.balance,
            code: event.code,
            type: event.type,
            date: event.date,
            display_date: event.display_date,
            comment: event.comment,
            universal_housing_username: event.universal_housing_username
          }
        end

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

      def transaction_date_summary(transactions)
        summarised_transactions = []

        incoming = transactions.partition { |v| v[:value].negative? }.first
        outgoing = transactions.partition { |v| v[:value].positive? }.first

        outgoing.group_by { |d| d[:timestamp] }.each do |date, t|
          summarised_transactions << { date: date, total_charge: charges(t), transactions: t }
        end

        incoming.group_by { |d| d[:timestamp] }.each do |date, t|
          summarised_transactions << { date: date, total_charge: charges(t), transactions: t }
        end

        summarised_transactions.sort_by { |summary| summary[:date] }.reverse
      end

      def charges(transactions)
        total = 0
        transactions.each do |t|
          total += t[:value]
        end
        total
      end
    end
  end
end
