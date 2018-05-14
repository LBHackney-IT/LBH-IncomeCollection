module Hackney
  module Income
    class StubTenancyGateway
      def get_tenancies_in_arrears()
        [
          create_tenancy_list_item(
            first_name: 'Clark',
            last_name: 'Kent',
            title: 'Mr',
            address_1: '1 Fortress of Solitude',
            tenancy_ref: '1234567'
          ),
          create_tenancy_list_item(
            first_name: 'Bruce',
            last_name: 'Wayne',
            title: 'Mr',
            address_1: '1 Wayne Manor',
            tenancy_ref: '2345678'
          ),
          create_tenancy_list_item(
            first_name: 'Diana',
            last_name: 'Prince',
            title: 'Ms',
            address_1: '1 Themyscira',
            tenancy_ref: '3456789'
          )
        ]
      end

      def get_tenancy(tenancy_ref:)
        case tenancy_ref
        when '1234567'
          create_tenancy(
            first_name: 'Clark',
            last_name: 'Kent',
            title: 'Mr',
            address_1: '1 Fortress of Solitude',
            tenancy_ref: '1234567'
          )
        when '2345678'
          create_tenancy(
            first_name: 'Bruce',
            last_name: 'Wayne',
            title: 'Mr',
            address_1: '1 Wayne Manor',
            tenancy_ref: '2345678'
          )
        when '3456789'
          create_tenancy(
            first_name: 'Diana',
            last_name: 'Prince',
            title: 'Ms',
            address_1: '1 Themyscira',
            tenancy_ref: '3456789'
          )
        end
      end

      private

      def create_tenancy_list_item(first_name:, last_name:, title:, tenancy_ref:, address_1:)
        {
          primary_contact: {
            first_name: first_name,
            last_name: last_name,
            title: title
          },
          address_1: address_1,
          tenancy_ref: tenancy_ref,
          current_balance: '-1200.99'
        }
      end

      def create_tenancy(first_name:, last_name:, title:, tenancy_ref:, address_1:)
        {
          ref: tenancy_ref,
          current_balance: '-1200.99',
          type: 'Temporary Accommodation',
          start_date: '2018-01-01',
          primary_contact: {
            first_name: first_name,
            last_name: last_name,
            title: title,
            contact_number: '0208 123 1234',
            email_address: 'test@example.com'
          },
          address: {
            address_1: address_1,
            address_2: 'Hackney',
            address_3: 'London',
            address_4: 'UK',
            post_code: 'E1 123'
          },
          transactions: [
            {
              type: 'payment',
              payment_method: 'Direct Debit',
              amount: '12.99',
              final_balance: '100.00',
              date: '2018-01-01'
            }
          ],
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
