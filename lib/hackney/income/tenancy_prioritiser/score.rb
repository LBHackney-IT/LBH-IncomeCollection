module Hackney
  module Income
    class TenancyPrioritiser
      class Score
        def initialize(criteria: criteria, weightings: weightings)
          @criteria = criteria
          @weightings = weightings
        end

        def execute

          score = 0

          score += balance
        end

        def balance
          @criteria.balance * @weightings.balance
        end

        def days_in_arrears
          @criteria.days_in_arrears * @weightings.days_in_arrears
        end

        def days_since_last_payment
          weeks_since_last_payment = @criteria.days_since_last_payment / 7
          weighting = @weightings.days_since_last_payment * weeks_since_last_payment

          @criteria.days_since_last_payment * weighting
        end
      end
    end
  end
end
