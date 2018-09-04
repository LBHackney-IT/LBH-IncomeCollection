module Hackney
  module Income
    class StubCreateActionDiaryEntry
      def initialize(action_diary_gateway:)
      end
      
      def execute(tenancy_ref:, balance:, code:, type:, date:, comment:, universal_housing_username:)
      end
    end
  end
end
