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
          @property_address = action_attributes[:metadata][:property_address]
          @lessee = action_attributes[:metadata][:lessee]
          @tenure_type = action_attributes[:metadata][:tenure_type]
          @direct_debit_status = action_attributes[:metadata][:direct_debit_status]
          @latest_letter = action_attributes[:metadata][:latest_letter]
          @latest_letter_date = parsed_date(action_attributes[:metadata][:latest_letter_date])
        end

        attr_reader :tenancy_ref, :payment_ref, :balance, :patch_code,
                    :classification, :pause_reason, :pause_comment,
                    :pause_until, :action_type, :service_area_type,
                    :property_address, :lessee, :tenure_type,
                    :latest_letter, :latest_letter_date, :direct_debit_status

        validates :tenancy_ref, :payment_ref, :balance,
                  :action_type, :service_area_type,
                  presence: true

        private

        def parsed_date(date)
          return if date.nil?

          Time.parse(date).to_formatted_s(:long_ordinal)
        end
      end
    end
  end
end
