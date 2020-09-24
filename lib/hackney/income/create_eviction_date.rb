module Hackney
  module Income
    class CreateEvictionDate
      def initialize(eviction_gateway:)
        @eviction_gateway = eviction_gateway
      end

      def execute(eviction_params:, username:)
        eviction_params = {
          tenancy_ref: eviction_params[:tenancy_ref],
          date: eviction_params[:eviction_date]
        }

        @eviction_gateway.create_eviction(params: eviction_params, username: username)
      end
    end
  end
end
