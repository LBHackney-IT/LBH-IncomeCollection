module Hackney
  module Income
    class CreateAgreement
      def initialize(agreement_gateway:)
        @agreement_gateway = agreement_gateway
      end

      def execute(tenancy_ref:, agreement_type:, frequency:, amount:, start_date:, created_by:, notes:, court_case_id:, initial_payment_amount:, initial_payment_date:)
        @agreement_gateway.create_agreement(
          tenancy_ref: tenancy_ref,
          agreement_type: agreement_type,
          frequency: frequency,
          amount: amount,
          start_date: start_date,
          created_by: created_by,
          notes: notes,
          court_case_id: court_case_id,
          initial_payment_amount: initial_payment_amount,
          initial_payment_date: initial_payment_date
        )
      end
    end
  end
end
