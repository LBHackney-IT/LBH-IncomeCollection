module Hackney
  module Income
    class StubTenancyGatewayBuilder
      GetTenanciesResponse = Struct.new(:tenancies, :paused, :page_number, :number_of_pages)

      class << self
        def build_stub(with_tenancies: DEFAULT_TENANCIES)
          build_gateway_class.tap do |gateway_class|
            gateway_class.default_tenancies = with_tenancies
          end
        end

        def build_failing_stub(with_tenancies: DEFAULT_TENANCIES)
          build_failing_class.tap {}
        end

        private

        def build_failing_class
          Class.new do
            def initialize(api_host: nil, api_key: nil, include_developer_data: nil); end

            def update_tenancy(tenancy_ref:, user_id:, action_code:, is_paused_until:, pause_reason:, pause_comment:)
              Net::HTTPClientError.new(1.1, 500, 'Internal server error')
            end
          end
        end

        def build_gateway_class
          Class.new do
            cattr_accessor :default_tenancies

            def initialize(api_host: nil, api_key: nil, include_developer_data: nil)
              @tenancies = default_tenancies
            end

            def get_tenancies(user_id:, page_number:, number_per_page:, paused: nil)
              cases = @tenancies
                .select { |t| t.fetch(:assigned_user_id) == user_id }
                .map(&method(:create_tenancy_list_item))

              number_of_pages = (cases.count.to_f / number_per_page).ceil
              GetTenanciesResponse.new(cases, paused, page_number, number_of_pages)
            end

            def get_tenancy(tenancy_ref:)
              tenancy = @tenancies.select { |t| t[:tenancy_ref] == tenancy_ref }.first
              create_tenancy(tenancy)
            end

            def update_tenancy(tenancy_ref:, user_id:, action_code:, is_paused_until:, pause_reason:, pause_comment:)
              tenancy = @tenancies.select { |t| t[:tenancy_ref] == tenancy_ref }.first
              create_tenancy(tenancy)
              Net::HTTPNoContent.new(1.1, 204, nil)
            end

            def get_contacts_for(tenancy_ref:)
              [
                generate_contact
              ]
            end

            private

            def generate_contact
              Hackney::Income::Domain::Contact.new.tap do |c|
                c.contact_id = '123456'
                c.email_address = 'test.email@email.server.com'
                c.uprn = '0'
                c.address_line_1 = '123'
                c.address_line_2 = 'Test Road'
                c.address_line_3 = 'Delivery City'
                c.first_name = 'Rich'
                c.last_name = 'Foster'
                c.full_name = 'Richard Foster'
                c.larn = '0'
                c.telephone_1 = '0101 1234'
                c.telephone_2 = '077777777'
                c.telephone_3 = nil
                c.cautionary_alert = false
                c.property_cautionary_alert = false
                c.house_ref = '98765'
                c.title = 'Mr.'
                c.full_address_display = '123 Test Road, Delivery City'
                c.full_address_search = 'Search'
                c.post_code = 'E0 123'
                c.date_of_birth = '12th March, 1976'
                c.hackney_homes_id = '1209'
                c.responsible = true
              end
            end

            def create_tenancy_list_item(attributes)
              Hackney::Income::Domain::TenancyListItem.new.tap do |t|
                t.primary_contact_name = get_name_from(attributes)
                t.ref = attributes.fetch(:tenancy_ref)
                t.current_balance = attributes.fetch(:current_balance, 1200.99)
                t.current_arrears_agreement_status = attributes.fetch(:current_arrears_agreement_status, '100')
                t.latest_action_code = attributes.fetch(:latest_action_code, 'Z00')
                t.latest_action_date = attributes.fetch(:latest_action_date, '2018-05-01 00:00:00')
                t.primary_contact_short_address = attributes.fetch(:address_1)
                t.primary_contact_postcode = attributes.fetch(:postcode, 'E1 123')
                t.score = attributes.fetch(:score, '123')
                t.band = attributes.fetch(:band, 'green')

                t.balance_contribution = 1
                t.days_in_arrears_contribution = 1
                t.days_since_last_payment_contribution = 1
                t.payment_amount_delta_contribution = 1
                t.payment_date_delta_contribution = 1
                t.number_of_broken_agreements_contribution = 1
                t.active_agreement_contribution = 1
                t.broken_court_order_contribution = 1
                t.nosp_served_contribution = 1
                t.active_nosp_contribution = 1

                t.days_in_arrears = 1
                t.days_since_last_payment = 1
                t.payment_amount_delta = 1
                t.payment_date_delta = 1
                t.number_of_broken_agreements = 1
                t.broken_court_order = false
                t.nosp_served = false
                t.active_nosp = false
              end
            end

            def get_name_from(attributes)
              [attributes.fetch(:title), attributes.fetch(:first_name), attributes.fetch(:last_name)].join(' ')
            end

            def create_tenancy(attributes)
              agreement = Hackney::Income::Domain::ArrearsAgreement.new.tap do |a|
                a.amount = '10.99'
                a.breached = false
                a.clear_by = '2018-11-01'
                a.frequency = 'weekly'
                a.start_balance = '99.00'
                a.start_date = '2018-01-01'
                a.status = 'active'
              end

              action = Hackney::Income::Domain::ActionDiaryEntry.new.tap do |a|
                a.balance = '100.00'
                a.code = 'GEN'
                a.type = 'general_note'
                a.date = '2018-01-01'
                a.comment = 'this tenant is in arrears!!!'
                a.universal_housing_username = 'Brainiac'
              end

              Hackney::Income::Domain::Tenancy.new.tap do |t|
                t.ref = attributes.fetch(:tenancy_ref)
                t.current_balance = 1200.99
                t.current_arrears_agreement_status = 'active'
                t.primary_contact_name = [attributes.fetch(:title), attributes.fetch(:first_name), attributes.fetch(:last_name)].join(' ')
                t.primary_contact_long_address = attributes.fetch(:address_1)
                t.primary_contact_postcode = 'E1 123'
                t.primary_contact_phone = Faker::PhoneNumber.phone_number
                t.primary_contact_email = 'test@example.com'
                t.arrears_actions = [action]
                t.agreements = [agreement]
                t.contacts = nil
              end
            end
          end
        end

        DEFAULT_TENANCIES = [
          {
            first_name: 'Clark',
            last_name: 'Kent',
            title: 'Mr',
            address_1: '1 Fortress of Solitude',
            tenancy_ref: '1234567',
            assigned_user_id: 123
          },
          {
            first_name: 'Bruce',
            last_name: 'Wayne',
            title: 'Mr',
            address_1: '1 Wayne Manor',
            tenancy_ref: '2345678',
            assigned_user_id: 123
          },
          {
            first_name: 'Diana',
            last_name: 'Prince',
            title: 'Ms',
            address_1: '1 Themyscira',
            tenancy_ref: '3456789',
            assigned_user_id: 123
          }
        ].freeze
        private_constant :DEFAULT_TENANCIES
      end
    end
  end
end
