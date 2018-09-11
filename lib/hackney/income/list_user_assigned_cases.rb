module Hackney
  module Income
    class ListUserAssignedCases
      Response = Struct.new(:tenancies, :page_number, :number_of_pages)

      def initialize(tenancy_assignment_gateway:, tenancy_gateway:)
        @tenancy_assignment_gateway = tenancy_assignment_gateway
        @tenancy_gateway = tenancy_gateway
      end

      def execute(user_id:, page_number: nil, count_per_page: nil)
        tenancies = @tenancy_assignment_gateway.assigned_tenancies(assignee_id: user_id)
        tenancy_refs = tenancies.map { |t| t.fetch(:ref) }
        paginated_tenancy_refs = paginate(tenancy_refs, page_number, count_per_page)

        tenancies = @tenancy_gateway.get_tenancies(paginated_tenancy_refs)
        number_of_pages = page_count(tenancies, count_per_page)

        Response.new(tenancies, page_number, number_of_pages)
      end

      private

      def paginate(list, page_number, count_per_page)
        return list if page_number.nil? || count_per_page.nil?
        return [] if list.empty?

        start_index = (page_number - 1) * count_per_page
        end_index = (page_number * count_per_page) - 1

        list[start_index..end_index]
      end

      def page_count(list, count_per_page)
        return if count_per_page.nil?
        actual_number = (list.count / count_per_page).ceil
        [1, actual_number].max
      end
    end
  end
end
