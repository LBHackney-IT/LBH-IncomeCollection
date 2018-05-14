module Hackney
  module Income
    class ReallyDangerousTenancyGateway
      def initialize(api_host:)
        @api_host = api_host
      end

      def get_tenancy(tenancy_ref:)
        response = HTTParty.get("#{@api_host}/v1/Accounts", query: { referencenumber: tenancy_ref })
        result = JSON.parse(response.body)['results'].first

        FAKE_DETAILS.clone.tap do |details|
          tenant = result.fetch('ListOfTenants').first
          address = result.fetch('ListOfAddresses').first

          details[:ref] = result.fetch('tagReferenceNumber')
          details[:current_balance] = result.fetch('currentBalance')

          details[:primary_contact].merge!(
            first_name: tenant.fetch('forename'),
            last_name: tenant.fetch('surname'),
            title: tenant.fetch('title')
          )

          details[:address].merge!(
            address_1: address.fetch('shortAddress'),
            post_code: address.fetch('postCode')
          )
        end
      end

      private

      FAKE_DETAILS = {
        type: 'Temporary Accommodation',
        start_date: '2018-01-01',
        primary_contact: {
          contact_number: '0208 123 1234',
          email_address: 'test@example.com'
        },
        address: {
          address_2: 'Hackney',
          address_3: 'London',
          address_4: 'UK'
        },
        transactions: [{
          type: 'payment',
          payment_method: 'Direct Debit',
          amount: '12.99',
          final_balance: '100.00',
          date: '2018-01-01'
        }],
        agreements: [{
          status: 'active',
          type: 'court_ordered',
          value: '10.99',
          frequency: 'weekly',
          created_date: '2017-11-01'
        }],
        arrears_actions: [{
          type: 'general_note',
          automated: false,
          user: { name: 'Rupert Giles' },
          date: '2018-01-01',
          description: '...'
        }]
      }
    end
  end
end