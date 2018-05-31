module Hackney
  module Income
    class SqlEventsGateway
      def create_event(tenancy_ref:, type:, description:, automated:)
        tenancy = Hackney::Models::Tenancy.find_or_create_by(ref: tenancy_ref)
        tenancy.tenancy_events.create!(event_type: type, description: description, automated: automated)

        nil
      end

      def events_for(tenancy_ref:)
        tenancy = Hackney::Models::Tenancy.find_by(ref: tenancy_ref)
        return [] if tenancy.nil?

        tenancy.tenancy_events.map do |event|
          {
            type: event.event_type,
            description: event.description,
            timestamp: event.created_at,
            automated: event.automated
          }
        end
      end
    end
  end
end
