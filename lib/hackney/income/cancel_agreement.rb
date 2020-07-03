module Hackney
  module Income
    class CancelAgreement
      def initialize(agreement_gateway:)
        @agreement_gateway = agreement_gateway
      end

      def execute(agreement_id:)
        @agreement_gateway.cancel_agreement(agreement_id: agreement_id)
      end
    end
  end
end
