module Hackney
  module Income
    module Types
      class TenancyListItem
        attr_accessor :ref, :current_balance, :current_arrears_agreement_status,
          :latest_action_code, :latest_action_date, :primary_contact_name,
          :primary_contact_short_address, :primary_contact_postcode
      end
    end
  end
end
