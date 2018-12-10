require 'date'
require 'ostruct'

module Hackney
  module Income
    class PauseTenancy
      include TenancyHelper

      def initialize(tenancy_gateway:)
        @tenancy_gateway = tenancy_gateway
      end

      def execute(tenancy_ref:)
        tenancy_pause = @tenancy_gateway.get_tenancy_pause(tenancy_ref: tenancy_ref)
        tenancy_pause[:action_code] = pause_reasons[tenancy_pause[:pause_reason]]
        tenancy_pause[:is_paused_until] = tenancy_pause[:is_paused_until] ? Date.parse(tenancy_pause[:is_paused_until]) : Date.today
        tenancy_pause
      end
    end
  end
end
