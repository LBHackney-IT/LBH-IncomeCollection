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
          format_date(start_date)
        end

        def display_assigned_to
          if case_priority.present?
            "#{case_priority.dig(:assigned_user, :name)} (#{case_priority.dig(:assigned_user, :role)})".titleize
          else
            'Not assigned'
          end
        end

        def display_priority_band
          case_priority[:priority_band]
        end

        def display_nosp_served
          format_date(case_priority[:nosp_served_date])
        end

        def display_nosp_expiry
          format_date(case_priority[:nosp_expiry_date])
        end

        def display_number_of_bedrooms
          return 'Unknown' if case_priority[:num_bedrooms].nil?
          case_priority[:num_bedrooms]
        end

        private

        def format_date(date)
          return '' if date.nil?
          Date.parse(date).to_formatted_s(:long_ordinal)
        end
      end
    end
  end
end
