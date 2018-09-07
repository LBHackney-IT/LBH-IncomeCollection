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

        def start_date_display_date
          Date.parse(start_date).to_formatted_s(:long_ordinal)
        end

        def clear_by_display_date
          Date.parse(clear_by).to_formatted_s(:long_ordinal)
        end
      end
    end
  end
end
