module Hackney
  module Income
    class SqlTenancyCaseGateway
      def persist(tenancies:)
        tenancies.each do |tenancy|
          Hackney::Models::Tenancy.find_or_create_by!(ref: tenancy.ref)
        end
      end

      def assign_user(tenancy_ref:, user_id:)
        tenancy = Hackney::Models::Tenancy.find_by(ref: tenancy_ref)
        tenancy.update!(assigned_user_id: user_id)
      end

      def assigned_tenancies(assignee_id:)
        Hackney::Models::Tenancy
          .where(assigned_user_id: assignee_id)
          .map { |t| { ref: t.ref } }
      end
    end
  end
end
