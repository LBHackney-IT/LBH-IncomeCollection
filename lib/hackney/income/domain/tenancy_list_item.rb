module Hackney
  module Income
    module Domain
      class TenancyListItem
        include ActiveModel::Validations

        attr_accessor :ref, :current_balance, :current_arrears_agreement_status,
                      :latest_action_code, :latest_action_date, :primary_contact_name,
                      :primary_contact_short_address, :primary_contact_postcode, :score, :band,
                      :balance_contribution, :days_in_arrears_contribution, :days_since_last_payment_contribution,
                      :payment_amount_delta_contribution, :payment_date_delta_contribution,
                      :number_of_broken_agreements_contribution, :active_agreement_contribution,
                      :broken_court_order_contribution, :nosp_served_contribution, :active_nosp_contribution,
                      :days_in_arrears, :days_since_last_payment, :payment_amount_delta,
                      :payment_date_delta, :number_of_broken_agreements, :broken_court_order,
                      :nosp_served, :active_nosp

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
