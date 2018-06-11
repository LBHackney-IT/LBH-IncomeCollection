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
              @cases_by_assignee = default_cases
            end

            def assigned_tenancies(assignee_id:)
              @cases_by_assignee.fetch(assignee_id, [])
            end

            def assign_user_case(assignee_id:, case_attributes:)
              @cases_by_assignee[assignee_id] ||= []
              @cases_by_assignee[assignee_id] << case_attributes
            end
          end
        end

        DEFAULT_CASES = [{
          address_1: Faker::Address.street_address,
          post_code: Faker::Address.postcode,
          current_balance: Faker::Number.decimal(2),
          tenancy_ref: Faker::IDNumber.valid,
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          title: Faker::Name.prefix
        }].freeze

        private_constant :DEFAULT_CASES
      end
    end
  end
end
