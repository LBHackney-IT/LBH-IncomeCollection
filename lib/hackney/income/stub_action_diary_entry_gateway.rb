module Hackney
  module Income
    class StubActionDiaryEntryGateway
      def initialize(api_host:, api_key:); end

      def create_action_diary_entry(tenancy_ref:, balance:, code:, type:, date:, comment:, universal_housing_username:); end
    end
  end
end
