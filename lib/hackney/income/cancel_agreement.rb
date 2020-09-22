module Hackney
  module Income
    class CancelAgreement
      def initialize(agreement_gateway:)
        @agreement_gateway = agreement_gateway
      end

      def execute(agreement_id:, cancelled_by:, cancellation_reason:)
        @agreement_gateway.cancel_agreement(
          agreement_id: agreement_id,
          cancelled_by: cancelled_by,
          cancellation_reason: cancellation_reason
        )
      end
    end
  end
end
