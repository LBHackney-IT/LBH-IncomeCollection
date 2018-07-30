module Hackney
  module Income
    class StubTenancyGatewayBuilder
      class << self
        def build_stub(with_tenancies: DEFAULT_TENANCIES)
          build_gateway_class.tap do |gateway_class|
            gateway_class.default_tenancies = with_tenancies
          end
        end

        private

        def build_gateway_class
          Class.new do
            cattr_accessor :default_tenancies

            def initialize(api_host: nil, api_key: nil, include_developer_data: nil)
              @tenancies = default_tenancies
            end

            def get_tenancies_in_arrears
              @tenancies.map(&method(:create_tenancy_list_item))
            end

            def get_tenancy(tenancy_ref:)
              tenancy = @tenancies.select { |t| t[:tenancy_ref] == tenancy_ref }.first
              create_tenancy(tenancy)
            end

            private

            def create_tenancy_list_item(attributes)
              Hackney::Income::Domain::TenancyListItem.new.tap do |t|
                t.primary_contact_name = get_name_from(attributes)
                t.ref = attributes.fetch(:tenancy_ref)
                t.current_balance = '1200.99'
                t.current_arrears_agreement_status = '100'
                t.latest_action_code = '101'
                t.latest_action_date = '2018-05-01 00:00:00'
                t.primary_contact_short_address = attributes.fetch(:address_1)
                t.primary_contact_postcode = 'E1 123'
              end
            end

            def get_name_from(attributes)
              [attributes.fetch(:title), attributes.fetch(:first_name), attributes.fetch(:last_name)].join(' ')
            end

            def create_tenancy(attributes)
              {
                ref: attributes.fetch(:tenancy_ref),
                current_balance: '1200.99',
                type: 'SEC',
                start_date: '2018-01-01',
                primary_contact: {
                  first_name: attributes.fetch(:first_name),
                  last_name: attributes.fetch(:last_name),
                  title: attributes.fetch(:title),
                  contact_number: '0208 123 1234',
                  email_address: 'test@example.com'
                },
                address: {
                  address_1: attributes.fetch(:address_1),
                  address_2: 'Hackney',
                  address_3: 'London',
                  address_4: 'UK',
                  post_code: 'E1 123'
                },
                agreements: [
                  {
                    status: 'active',
                    type: 'court_ordered',
                    value: '10.99',
                    frequency: 'weekly',
                    created_date: '2017-11-01'
                  }
                ],
                arrears_actions: [
                  {
                    type: 'general_note',
                    automated: false,
                    user: {
                      name: 'Brainiac'
                    },
                    date: '2018-01-01',
                    description: 'this tenant is in arrears!!!'
                  }
                ]
              }
            end
          end
        end

        DEFAULT_TENANCIES = [
          {
            first_name: 'Clark',
            last_name: 'Kent',
            title: 'Mr',
            address_1: '1 Fortress of Solitude',
            tenancy_ref: '1234567'
          },
          {
            first_name: 'Bruce',
            last_name: 'Wayne',
            title: 'Mr',
            address_1: '1 Wayne Manor',
            tenancy_ref: '2345678'
          },
          {
            first_name: 'Diana',
            last_name: 'Prince',
            title: 'Ms',
            address_1: '1 Themyscira',
            tenancy_ref: '3456789'
          }
        ].freeze
        private_constant :DEFAULT_TENANCIES
      end
    end
  end
end
