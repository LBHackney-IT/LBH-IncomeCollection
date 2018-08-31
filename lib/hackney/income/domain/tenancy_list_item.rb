module Hackney
  module Income
    module Domain
      class TenancyListItem
        include ActiveModel::Validations

        attr_accessor :ref, :current_balance, :current_arrears_agreement_status,
                      :latest_action_code, :latest_action_date, :primary_contact_name,
                      :primary_contact_short_address, :primary_contact_postcode, :score, :band

        validates :ref, :current_balance, :current_arrears_agreement_status,
                  :latest_action_code, :latest_action_date, :primary_contact_name,
                  :primary_contact_short_address, :primary_contact_postcode,
                  presence: true

        def human_readable_agreement_status
          return 'Active' if current_arrears_agreement_status == '200'
          return 'Breached' if current_arrears_agreement_status == '400'
          return 'Inactive' if current_arrears_agreement_status == '300'
          'None'
        end
      end
    end
  end
end
