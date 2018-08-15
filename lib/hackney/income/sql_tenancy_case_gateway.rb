module Hackney
  module Income
    class SqlTenancyCaseGateway
      def persist(tenancies:)
        tenancies.each do |tenancy|
          record = Hackney::Models::Tenancy.find_or_create_by!(ref: tenancy.ref)
          record.update!(
            primary_contact_short_address: tenancy.primary_contact_short_address,
            primary_contact_postcode: tenancy.primary_contact_postcode,
            ref: tenancy.ref,
            current_balance: tenancy.current_balance,
            primary_contact_name: tenancy.primary_contact_name,
            latest_action_code: tenancy.latest_action_code,
            latest_action_date: tenancy.latest_action_date,
            current_arrears_agreement_status: tenancy.current_arrears_agreement_status,
            score: tenancy.score,
            band: tenancy.band
          )
        end
      end

      def assign_user(tenancy_ref:, user_id:)
        tenancy = Hackney::Models::Tenancy.find_by(ref: tenancy_ref)
        tenancy.update!(assigned_user_id: user_id)
      end

      def assigned_tenancies(assignee_id:)
        Hackney::Models::Tenancy
          .where(assigned_user_id: assignee_id)
          .map do |tenancy|
            {
              ref: tenancy.ref,
              primary_contact_short_address: tenancy.primary_contact_short_address,
              primary_contact_postcode: tenancy.primary_contact_postcode,
              primary_contact_name: tenancy.primary_contact_name,
              current_balance: tenancy.current_balance,
              current_arrears_agreement_status: tenancy.current_arrears_agreement_status,
              latest_action_code: tenancy.latest_action_code,
              latest_action_date: tenancy.latest_action_date,
              score: tenancy.score,
              band: tenancy.band
            }
          end
      end
    end
  end
end
