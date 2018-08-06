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
      end
    end
  end
end
