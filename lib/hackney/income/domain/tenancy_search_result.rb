module Hackney
  module Income
    module Domain
      class TenancySearchResult
        include ActiveModel::Validations

        attr_accessor :ref, :property_ref, :tenure,
                      :current_balance, :current_arrears_agreement_status,
                      :primary_contact_name, :primary_contact_short_address, :primary_contact_postcode,
                      :arrears_agreement_start_date,
                      :last_action_code, :last_action_date

        validates :ref, :current_balance, :current_arrears_agreement_status,
                  :primary_contact_name, :primary_contact_long_address,
                  :primary_contact_postcode,
                  presence: true
      end
    end
  end
end
