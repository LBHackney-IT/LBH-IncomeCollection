module Hackney
  module Income
    class StubTenancyCaseGatewayBuilder
      class << self
        def build_stub(cases: DEFAULT_CASES)
          build_gateway_class.tap do |gateway_class|
            gateway_class.default_cases = cases
          end
        end

        def build_gateway_class
          Class.new do
            cattr_accessor :default_cases

            def initialize
              @cases_by_assignee = default_cases.dup
            end

            def assigned_tenancies(assignee_id:)
              @cases_by_assignee.fetch(assignee_id, [])
            end

            def assign_user(tenancy_ref:, assignee_id:)
              @cases_by_assignee[assignee_id] ||= []
              @cases_by_assignee[assignee_id] << { ref: tenancy_ref }
            end
          end
        end

        DEFAULT_CASES = [{ tenancy_ref: Faker::IDNumber.valid }].freeze
        private_constant :DEFAULT_CASES
      end
    end
  end
end
