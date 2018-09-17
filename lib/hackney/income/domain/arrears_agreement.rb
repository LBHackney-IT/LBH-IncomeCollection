module Hackney
  module Income
    module Domain
      class ArrearsAgreement
        include ActiveModel::Validations

        attr_accessor :amount, :breached, :clear_by, :frequency, :start_balance,
                      :start_date, :status

        validates :amount, :breached, :clear_by, :frequency, :start_balance,
                  :start_date, :status,
                  presence: true

        def amount_with_precision
          ActionController::Base.helpers.number_with_precision(amount, precision: 2)
        end

        def start_balance_with_precision
          ActionController::Base.helpers.number_with_precision(start_balance, precision: 2)
        end

        def start_date_display_date
          Date.parse(start_date).to_formatted_s(:long_ordinal)
        end

        def clear_by_display_date
          Date.parse(clear_by).to_formatted_s(:long_ordinal)
        end

        def human_readable_agreement_status
          return 'Active' if status == '200'
          return 'Breached' if status == '400'
          return 'Inactive' if status == '300'
          'None'
        end

        def human_readable_breached_status
          breached ? 'Yes' : 'No'
        end

        def human_readable_frequency
          return 'Weekly' if frequency == '1'
          return 'Monthly' if frequency == '0'
          frequency
        end
      end
    end
  end
end
