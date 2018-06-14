module Hackney
  module Income
    class TenancyPrioritiser
      class Score
        def initialize(criteria, weightings)
          @criteria = criteria
          @weightings = weightings
        end

        def execute
          normalised_score
        end

        def normalised_score
          ((score - @criteria.balance) / 10).round
        end

        def score
          score = 0

          score += balance
          score += days_in_arrears
          score += days_since_last_payment
          score += payment_amount_delta
          score += payment_date_delta
          score += number_of_broken_agreements
          score += active_agreement || 0
          score += broken_court_order || 0
          score += nosp_served || 0
          score += active_nosp || 0

          score
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

        def payment_amount_delta
          return 0 if @criteria.payment_amount_delta.nil?
          @criteria.payment_amount_delta * @weightings.payment_amount_delta
        end

        def payment_date_delta
          return 0 if @criteria.payment_date_delta.nil?
          @criteria.payment_date_delta.abs * @weightings.payment_date_delta
        end

        def number_of_broken_agreements
          agreement_additional_penalty = @criteria.number_of_broken_agreements > 3 ? 50 : 0

          (@criteria.number_of_broken_agreements * @weightings.number_of_broken_agreements) + agreement_additional_penalty
        end

        def active_agreement
          @weightings.active_agreement if @criteria.active_agreement?
        end

        def broken_court_order
          @weightings.broken_court_order if @criteria.broken_court_order?
        end

        def nosp_served
          @weightings.nosp_served if @criteria.nosp_served? && !@criteria.active_nosp?
        end

        def active_nosp
          @weightings.active_nosp if @criteria.active_nosp?
        end
      end
    end
  end
end
