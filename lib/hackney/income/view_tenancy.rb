require 'date'
require 'ostruct'

module Hackney
  module Income
    class ViewTenancy
      def initialize(tenancy_gateway:, transactions_gateway:, scheduler_gateway:, events_gateway:, demo: false)
        @tenancy_gateway = tenancy_gateway
        @transactions_gateway = transactions_gateway
        @scheduler_gateway = scheduler_gateway
        @events_gateway = events_gateway
        @demo = demo
      end

      def execute(tenancy_ref:)
        return demo_tenancy(tenancy_ref: tenancy_ref) if @demo

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
            t.code = 'AUTO'
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

      def demo_tenancy(tenancy_ref:)
        agreement = Hackney::Income::Domain::ArrearsAgreement.new.tap do |a|
          a.amount = '10.99'
          a.breached = false
          a.clear_by = '2018-11-01'
          a.frequency = 'weekly'
          a.start_balance = '99.00'
          a.start_date = '2018-01-01'
          a.status = 'active'
        end

        action = Hackney::Income::Domain::ActionDiaryEntry.new.tap do |a|
          a.balance = '100.00'
          a.code = '101'
          a.type = 'general_note'
          a.date = '2018-01-01'
          a.comment = 'this tenant is in arrears!!!'
          a.universal_housing_username = 'Brainiac'
        end

        Hackney::Income::Domain::Tenancy.new.tap do |t|
          t.ref = tenancy_ref
          t.current_balance = '100.00'
          t.current_arrears_agreement_status = 'active'
          t.primary_contact_name = 'Mr Test Tenancy'
          t.primary_contact_long_address = '1, Test Lane, Delivery City'
          t.primary_contact_postcode = 'TE01 ST'
          t.primary_contact_phone = ENV['TEST_PHONE_NUMBER'] || 'set env TEST_PHONE_NUMBER'
          t.primary_contact_email = ENV['TEST_EMAIL_ADDRESS'] || 'set env TEST_EMAIL_ADDRESS'
          t.arrears_actions = [action]
          t.agreements = [agreement]
          t.transactions = fake_transactions
          t.scheduled_actions = [{
            scheduled_for: Date.tomorrow.noon,
            description: 'Test scheduled action',
            tenancy_ref: tenancy_ref
          }]
        end
      end

      def fake_transactions
        Hackney::Income::TransactionsBalanceCalculator.new.with_final_balances(current_balance: 100.00, transactions:
          Hackney::Income::TransactionsGateway.new(api_host: 'fake', include_developer_data: true).transactions_for(tenancy_ref: '0000001/FAKE'))
      end
    end
  end
end
