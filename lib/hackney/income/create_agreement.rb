module Hackney
  module Income
    class CreateAgreement
      def initialize(agreement_gateway:)
        @agreement_gateway = agreement_gateway
      end

      def execute(tenancy_ref:, agreement_type: 'informal', frequency:, amount:, start_date:, created_by:, notes:)
        @agreement_gateway.create_agreement(
          tenancy_ref: tenancy_ref,
          agreement_type: agreement_type,
          frequency: frequency,
          amount: amount,
          start_date: start_date,
          created_by: created_by,
          notes: notes
        )
      end
    end
  end
end
