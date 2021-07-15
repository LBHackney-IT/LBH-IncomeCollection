module Hackney
  module Income
    class CreateNospDates
      def initialize(nosp_gateway:)
        @nosp_gateway = nosp_gateway
      end

      def execute(nosp_params:, username:)
        nosp_params = {
          tenancy_ref: nosp_params[:tenancy_ref],
          nosp_served_date: nosp_params[:nosp_served_date]
        }

        @nosp_gateway.create_nosp(params: nosp_params, username: username)
      end
    end
  end
end
