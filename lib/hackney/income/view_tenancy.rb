require 'date'
require 'ostruct'

module Hackney
  module Income
    class ViewTenancy
      def initialize(tenancy_gateway:, transactions_gateway:)
        @tenancy_gateway = tenancy_gateway
        @transactions_gateway = transactions_gateway
      end

      def execute(tenancy_ref:)
        tenancy = @tenancy_gateway.get_tenancy(tenancy_ref: tenancy_ref)
        transactions = @transactions_gateway.transactions_for(tenancy_ref: tenancy_ref)
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
            phone_numbers: [contact.telephone_1, contact.telephone_2, contact.telephone_3],
            cautionary_alert: contact.cautionary_alert,
            property_cautionary_alert: contact.property_cautionary_alert,
            house_ref: contact.house_ref,
            title: contact.title,
            full_address_display: contact.full_address_display,
            full_address_search: contact.full_address_search,
            post_code: contact.post_code,
            date_of_birth: contact.date_of_birth,
            hackney_homes_id: contact.hackney_homes_id,
            responsible: contact.responsible
          }
        end

        tenancy.transactions = transactions_balance_calculator.organise_with_final_balances(
          current_balance: tenancy.current_balance.to_f,
          transactions: transactions
        )

        # tenancy.transactions = transaction_date_summary(tenancy.transactions)

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

        # tenancy.scheduled_actions = scheduled_actions.map do |action|
        #   {
        #     scheduled_for: action.fetch(:scheduled_for),
        #     description: action.fetch(:description)
        #   }
        # end

        tenancy
      end

      private

      # def transaction_date_summary(transactions)
      #   summarised_transactions = []
      #
      #   incoming = transactions.select { |v| v[:value].negative? }
      #   outgoing = transactions.select { |v| v[:value].positive? }
      #   weeks = []
      #
      #   outgoing.group_by { |d| d[:timestamp] }.each do |date, t|
      #     weeks << {
      #       week_no: date.cweek,
      #       week: date.all_week,
      #       year: date.year,
      #       incoming: 0,
      #       outgoing: 0,
      #       final_balance: 0,
      #       summarised_transactions: []
      #     }
      #     summarised_transactions <<
      #       {
      #         description: outgoing_description(t),
      #         date: date,
      #         total_charge: t.sum { |c| c.fetch(:value) },
      #         final_balance: t.first.fetch(:final_balance),
      #         transactions: t
      #       }
      #   end
      #
      #   incoming.group_by { |d| d[:timestamp] }.each do |date, t|
      #     weeks << {
      #       week_no: date.cweek,
      #       week: date.all_week,
      #       year: date.year,
      #       incoming: 0,
      #       outgoing: 0,
      #       final_balance: 0,
      #       summarised_transactions: []
      #     }
      #     summarised_transactions <<
      #       {
      #         description: incoming_description(t),
      #         date: date,
      #         total_charge: t.sum { |c| c.fetch(:value) },
      #         final_balance: t.first.fetch(:final_balance),
      #         transactions: t
      #       }
      #   end
      #   weeks = weeks.uniq
      #
      #   summarised_transactions.sort_by { |summary| summary[:date] }.reverse.each do |t|
      #     week = weeks.select { |w| w[:year] == t[:date].year && w[:week_no] == t[:date].cweek }.first
      #     week[:summarised_transactions] << t
      #     week[:summarised_transactions] = week[:summarised_transactions].sort_by { |s_t| s_t[:date] }.reverse
      #   end
      #
      #   weeks.each do |week|
      #     week[:summarised_transactions].reverse.each do |summary|
      #       if summary[:total_charge].positive?
      #         week[:outgoing] = week[:outgoing] + summary[:total_charge]
      #       end
      #       if summary[:total_charge].negative?
      #         week[:incoming] = week[:incoming] + summary[:total_charge]
      #       end
      #       week[:final_balance] = summary[:final_balance]
      #     end
      #   end
      #   weeks
      # end

      def incoming_description(transactions)
        return transactions.first.fetch(:description) if transactions.size == 1
        'Incoming payments'
      end

      def outgoing_description(transactions)
        return transactions.first.fetch(:description) if transactions.size == 1
        'Outgoing charges'
      end
    end
  end
end
