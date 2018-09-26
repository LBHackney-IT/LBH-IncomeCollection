module Hackney
  module Income
    class ViewActions
      def initialize(actions_gateway:)
        @actions_gateway = actions_gateway
      end

      def execute(tenancy_ref:)
        actions = @actions_gateway.get_actions_for(tenancy_ref: tenancy_ref)
        actions.map do |a|
          {
            balance: a.balance,
            code: a.code,
            type: a.type,
            date: a.date,
            display_date: a.display_date,
            comment: a.comment,
            universal_housing_username: a.universal_housing_username
          }
        end
      end
    end
  end
end
