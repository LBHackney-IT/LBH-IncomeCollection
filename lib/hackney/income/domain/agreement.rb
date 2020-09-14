module Hackney
  module Income
    module Domain
      class Agreement
        include ActiveModel::Validations

        attr_accessor :id, :tenancy_ref, :agreement_type, :starting_balance, :amount,
                      :start_date, :current_state, :created_at, :created_by, :frequency,
                      :last_checked, :court_case_id, :notes, :initial_payment_amount, :initial_payment_date, :history

        validates :tenancy_ref, :agreement_type, :amount, :frequency, :start_date, presence: true

        validates :court_case_id, presence: true, if: proc { |a| a.agreement_type == 'formal' }

        def initialize(attributes = {})
          @tenancy_ref = attributes[:tenancy_ref]
          @agreement_type = attributes[:agreement_type]
          @starting_balance = attributes[:starting_balance]
          @amount = attributes[:amount]
          @frequency = attributes[:frequency]&.humanize
          @start_date = attributes[:start_date].nil? ? (Date.today + 1.day).to_s : attributes[:start_date]
          @notes = attributes[:notes]
          @court_case_id = attributes[:court_case_id]
          @initial_payment_amount = attributes[:initial_payment_amount]
          @initial_payment_date = attributes[:initial_payment_date]
        end

        def start_date_display_date
          Date.parse(start_date).to_formatted_s(:long_ordinal)
        end

        def formal?
          agreement_type == 'formal'
        end

        def informal?
          !formal?
        end

        def cancelled?
          current_state == 'cancelled'
        end

        def breached?
          current_state == 'breached'
        end

        def variable_payment?
          initial_payment_amount.present?
        end

        def one_off_payment?
          frequency == 'one_off'
        end
      end
    end
  end
end
