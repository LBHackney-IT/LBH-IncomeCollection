module Hackney
  module Income
    class TestTenancyGateway
      def initialize(api_host: nil); end

      def get_tenancies_in_arrears
        [
          create_tenancy_list_item(
            first_name: 'Richard',
            last_name: 'Foster',
            title: 'Mr',
            tenancy_ref: '000001/01'
          )
        ]
      end

      def get_tenancy(tenancy_ref:)
        case tenancy_ref
        when '000001/01'
          create_tenancy(
            first_name: 'Richard',
            last_name: 'Foster',
            title: 'Mr',
            phone_number: '07956 095837',
            email_address: 'richard@madetech.com',
            tenancy_ref: '000001/01'
          )
        end
      end

      private

      def create_tenancy_list_item(first_name:, last_name:, title:, tenancy_ref:)
        {
          primary_contact: {
            first_name: first_name,
            last_name: last_name,
            title: title
          },
          address_1: '123 Test Street',
          post_code: 'E1 123',
          tenancy_ref: tenancy_ref,
          current_balance: '1200.99'
        }
      end

      def create_tenancy(first_name:, last_name:, title:, tenancy_ref:, phone_number:, email_address:)
        {
          ref: tenancy_ref,
          current_balance: 1200.99,
          type: 'SEC',
          start_date: '2018-01-01',
          primary_contact: {
            first_name: first_name,
            last_name: last_name,
            title: title,
            contact_number: phone_number,
            email_address: email_address
          },
          address: {
            address_1: '123 Test Street',
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
end
