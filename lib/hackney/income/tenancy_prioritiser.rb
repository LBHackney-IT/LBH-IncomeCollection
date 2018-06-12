module Hackney
  module Income
    class TenancyPrioritiser
      def initialize(tenancy:, transactions:)
        @criteria = Hackney::Income::TenancyPrioritiser::Criteria.new(tenancy, transactions)
      end

      def assign_priority_band
        Hackney::Income::TenancyPrioritiser::Band.new.execute(criteria: @criteria)
      end
    end
  end
end
