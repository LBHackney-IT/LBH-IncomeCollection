module Hackney
  module Income
    class TenancyPrioritiser
      class PriorityWeightings
        attr_accessor :balance, :days_in_arrears, :days_since_last_payment

        def balance
          @balance || 1.2
        end

        def days_in_arrears
          @days_in_arrears || 1.5
        end

        def days_since_last_payment
          @days_since_last_payment || 1
        end
      end
    end
  end
end
