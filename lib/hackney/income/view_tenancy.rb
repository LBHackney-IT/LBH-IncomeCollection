require 'date'
require 'ostruct'

module Hackney
  module Income
    class ViewTenancy
      def initialize(tenancy_gateway:)
        @tenancy_gateway = tenancy_gateway
      end

      def execute(tenancy_ref:)
        tenancy = @tenancy_gateway.get_tenancy(tenancy_ref: tenancy_ref)

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

          t.transactions = tenancy.fetch(:transactions).map do |transaction|
            {
              type: transaction.fetch(:type),
              payment_method: transaction.fetch(:payment_method),
              amount: transaction.fetch(:amount),
              date: Date.parse(transaction.fetch(:date)),
              final_balance: transaction.fetch(:final_balance),
            }
          end

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
              user: {
                name: action.dig(:user, :name)
              },
              date: Date.parse(action.fetch(:date)),
              description: action.fetch(:description)
            }
          end
        end
      end
    end
  end
end
