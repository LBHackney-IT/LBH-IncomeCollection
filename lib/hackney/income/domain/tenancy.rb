module Hackney
  module Income
    module Domain
      class Tenancy
        include ActiveModel::Validations

        attr_accessor :ref, :current_balance, :current_arrears_agreement_status,
                      :primary_contact_name, :primary_contact_long_address, :case_priority,
                      :primary_contact_postcode, :transactions, :arrears_actions, :agreements,
                      :scheduled_actions, :primary_contact_phone, :primary_contact_email,
                      :num_bedrooms, :tenure, :rent, :service, :other_charge, :start_date,
                      :contacts, :payment_ref, :timeline

        validates :ref, :current_balance, :current_arrears_agreement_status,
                  :primary_contact_name, :primary_contact_long_address,
                  :primary_contact_postcode,
                  presence: true

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

        def nosp
          @nosp ||= Hackney::Income::Domain::Nosp.new(case_priority[:nosp])
        end

        def display_number_of_bedrooms
          num_bedrooms
        end

        def patch_code
          case_priority[:patch_code]
        end

        def court_date
          case_priority[:courtdate]
        end

        def court_outcome
          case_priority[:court_outcome]
        end

        def eviction_date
          case_priority[:eviction_date]
        end

        def next_recommended_action
          case_priority[:classification]
        end
      end
    end
  end
end
