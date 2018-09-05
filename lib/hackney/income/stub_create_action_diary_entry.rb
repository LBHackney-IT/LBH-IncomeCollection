module Hackney
  module Income
    class StubCreateActionDiaryEntry
      def initialize(action_diary_gateway:)
      end

      def execute(tenancy_ref:, balance:, code:, type:, date:, comment:, universal_housing_username:)
        # @last_call = {
        #   tenancy_ref: tenancy_ref,
        #   balance: balance,
        #   code: code,
        #   type: type,
        #   comment: comment,
        #   universal_housing_username: universal_housing_username
        # }
      end

      # def last_call
      #   @last_call
      # end
    end
  end
end
