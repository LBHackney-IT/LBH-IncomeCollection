module Hackney
  module Income
    module Domain
      class Tenancy
        include ActiveModel::Validations

        attr_accessor :ref, :current_balance, :current_arrears_agreement_status,
                      :primary_contact_name, :primary_contact_long_address,
                      :primary_contact_postcode, :transactions, :arrears_actions, :agreements,
                      :scheduled_actions, :primary_contact_phone, :primary_contact_email,
                      :tenure, :rent, :service, :other_charge, :start_date, :contacts

        validates :ref, :current_balance, :current_arrears_agreement_status,
                  :primary_contact_name, :primary_contact_long_address,
                  :primary_contact_postcode,
                  presence: true
      end
    end
  end
end
