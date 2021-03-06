require 'date'
require 'ostruct'

module Hackney
  module Income
    class ViewTenancy
      def initialize(tenancy_gateway:, transactions_gateway:, case_priority_gateway:, get_diary_entries_gateway:)
        @tenancy_gateway = tenancy_gateway
        @transactions_gateway = transactions_gateway
        @case_priority_gateway = case_priority_gateway
        @get_diary_entries_gateway = get_diary_entries_gateway
      end

      def execute(tenancy_ref:)
        tenancy = @tenancy_gateway.get_tenancy(tenancy_ref: tenancy_ref)
        transactions = @transactions_gateway.transactions_for(tenancy_ref: tenancy_ref)

        actions = @get_diary_entries_gateway.get_actions_for(tenancy_ref: tenancy_ref).map do |a|
          {
            balance: a.balance,
            code: a.code,
            type: a.type,
            date: Time.zone.parse(a.date),
            display_date: a.display_date,
            comment: a.comment,
            universal_housing_username: a.universal_housing_username
          }
        end

        tenancy.timeline = Hackney::Income::Timeline.build(
          tenancy_ref: tenancy_ref,
          current_balance: tenancy.current_balance,
          actions: actions,
          transactions: transactions
        )

        tenancy.case_priority = @case_priority_gateway.get_case_priority(tenancy_ref: tenancy_ref)

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

        # tenancy.scheduled_actions = scheduled_actions.map do |action|
        #   {
        #     scheduled_for: action.fetch(:scheduled_for),
        #     description: action.fetch(:description)
        #   }
        # end

        tenancy
      end

      private

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
