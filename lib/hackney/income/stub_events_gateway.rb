module Hackney
  module Income
    class StubEventsGateway
      def initialize
        @events = []
      end

      def create_event(tenancy_ref:, type:, description:, automated:)
        @events << {
          tenancy_ref: tenancy_ref,
          type: type,
          description: description,
          timestamp: Time.now.utc,
          automated: automated
        }
      end

      def events_for(tenancy_ref:)
        @events.select { |event| event[:tenancy_ref] == tenancy_ref }
      end
    end
  end
end
