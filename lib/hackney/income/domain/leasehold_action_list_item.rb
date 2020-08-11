module Hackney
  module Income
    module Domain
      class LeaseholdActionListItem
        include ActiveModel::Validations

        def initialize(action_attributes)
          @tenancy_ref = action_attributes[:tenancy_ref]
          @payment_ref = action_attributes[:payment_ref]
          @balance = action_attributes[:balance]
          @patch_code = action_attributes[:patch_code]
          @classification = action_attributes[:classification]
          @pause_reason = action_attributes[:pause_reason]
          @pause_comment = action_attributes[:pause_comment]
          @pause_until = action_attributes[:pause_until]
          @action_type = action_attributes[:action_type]
          @service_area_type = action_attributes[:service_area_type]
          @metadata = action_attributes[:metadata]
        end

        attr_accessor :tenancy_ref, :payment_ref, :balance, :patch_code,
                      :classification, :pause_reason, :pause_comment,
                      :pause_until, :action_type, :service_area_type, :metadata

        validates :tenancy_ref, :payment_ref, :balance,
                  :action_type, :service_area_type, :metadata,
                  presence: true

        def property_address
          metadata[:property_address]
        end

        def lessee
          metadata[:lessee]
        end

        def tenure_type
          metadata[:tenure_type]
        end

        def direct_debit_status
          metadata[:direct_debit_status]
        end

        def latest_letter
          metadata[:latest_letter]
        end

        def latest_letter_date
          return if metadata[:latest_letter_date].nil?

          Time.parse(metadata[:latest_letter_date]).to_formatted_s(:long_ordinal)
        end
      end
    end
  end
end
