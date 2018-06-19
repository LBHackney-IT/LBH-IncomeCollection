module Hackney
  module Income
    class TenancyPrioritiser
      def initialize(tenancy:, transactions:, weightings:)
        @criteria = Hackney::Income::TenancyPrioritiser::Criteria.new(tenancy, transactions)
        @weightings = weightings
      end

      def score_adjusted_band
        band = assign_priority_band
        score = assign_priority_score

        return :amber if band == :green && score > 150 && !@criteria.active_agreement?
        return :red if band != :green && score > 500
        band
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
