module Hackney
  module Income
    class TenancyPrioritiser
      def initialize(tenancy:, transactions:, weightings:)
        @criteria = Hackney::Income::TenancyPrioritiser::Criteria.new(tenancy, transactions)
        @weightings = weightings
      end

      def assign_priority_band
        Hackney::Income::TenancyPrioritiser::Band.new.execute(criteria: @criteria)
      end

      def assign_priority_score
        Hackney::Income::TenancyPrioritiser::Score.new(@criteria, @weightings).execute
      end
    end
  end
end
