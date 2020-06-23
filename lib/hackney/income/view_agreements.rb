module Hackney
  module Income
    class ViewAgreements
      def initialize(agreement_gateway:)
        @agreement_gateway = agreement_gateway
      end

      def execute(tenancy_ref:)
        @agreement_gateway.view_agreements(
          tenancy_ref: tenancy_ref
        )
      end
    end
  end
end
