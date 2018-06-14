module Hackney
  module Income
    class SqlTenancyCaseGateway
      def persist(tenancy:)
        record = Hackney::Models::Tenancy.find_or_create_by!(ref: tenancy.fetch(:tenancy_ref))
        record.update!(
          address_1: tenancy.fetch(:address_1),
          post_code: tenancy.fetch(:post_code),
          ref: tenancy.fetch(:tenancy_ref),
          current_balance: tenancy.fetch(:current_balance),
          priority_band: tenancy.fetch(:priority_band),
          primary_contact_first_name: tenancy.dig(:primary_contact, :first_name),
          primary_contact_last_name: tenancy.dig(:primary_contact, :last_name),
          primary_contact_title: tenancy.dig(:primary_contact, :title)
        )
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
              tenancy_ref: tenancy.ref,
              address_1: tenancy.address_1,
              post_code: tenancy.post_code,
              current_balance: tenancy.current_balance,
              priority_band: tenancy.priority_band,
              first_name: tenancy.primary_contact_first_name,
              last_name: tenancy.primary_contact_last_name,
              title: tenancy.primary_contact_title
            }
          end
      end
    end
  end
end
