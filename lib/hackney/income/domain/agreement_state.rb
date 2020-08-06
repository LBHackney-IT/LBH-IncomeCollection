module Hackney
  module Income
    module Domain
      class AgreementState
        include ActiveModel::Validations

        attr_accessor :state, :date, :checked_balance, :expected_balance, :description

        validates_presence_of :state, :date
      end
    end
  end
end
