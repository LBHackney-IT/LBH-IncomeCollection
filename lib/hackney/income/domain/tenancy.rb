module Hackney
  module Income
    module Domain
      class Tenancy
        include ActiveModel::Validations

        attr_accessor :ref, :current_balance, :current_arrears_agreement_status,
                      :primary_contact_name, :primary_contact_long_address, :case_priority,
                      :primary_contact_postcode, :transactions, :arrears_actions, :agreements,
                      :scheduled_actions, :primary_contact_phone, :primary_contact_email,
                      :tenure, :rent, :service, :other_charge, :start_date, :contacts, :payment_ref

        validates :ref, :current_balance, :current_arrears_agreement_status,
                  :primary_contact_name, :primary_contact_long_address,
                  :primary_contact_postcode,
                  presence: true

        def display_start_date
          return '' if start_date.nil?
          Time.parse(start_date).to_formatted_s(:long_ordinal)
        end

        def display_assigned_to
          if case_priority
            "#{case_priority.dig(:assigned_user, :name)} (#{case_priority.dig(:assigned_user, :role)})".titleize
          else
            'Not assigned'
          end
        end

        def display_band
          "#{case_priority[:priority_band]}"
        end
      end
    end
  end
end
