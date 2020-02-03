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
                      :nosp_served, :active_nosp, :classification, :patch_code, :courtdate,
                      :eviction_date, :pause_reason, :pause_comment, :is_paused_until

        validates :ref, :current_balance, :current_arrears_agreement_status,
                  :latest_action_code, :latest_action_date, :primary_contact_name,
                  :primary_contact_short_address, :primary_contact_postcode,
                  presence: true

        def last_action_display_date
          return if latest_action_date.nil?
          Time.parse(latest_action_date).to_formatted_s(:long_ordinal)
        end
      end
    end
  end
end
