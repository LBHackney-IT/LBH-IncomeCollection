module Hackney
  module Income
    module Domain
      class TenancySearchResult
        include ActiveModel::Validations

        attr_accessor :ref, :property_ref, :tenure, :current_balance,
                      :primary_contact_name, :primary_contact_short_address, :primary_contact_postcode

        validates :ref, :current_balance, :tenure, :current_balance,
                  :primary_contact_name, :primary_contact_long_address, :primary_contact_postcode,
                  presence: true
      end
    end
  end
end
