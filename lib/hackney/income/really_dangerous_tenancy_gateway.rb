module Hackney
  module Income
    class ReallyDangerousTenancyGateway
      def initialize(api_host:)
        @api_host = api_host
      end

      def get_tenancy(tenancy_ref:)
        response = RestClient.get("#{@api_host}/v1/Accounts/AccountDetailsByPaymentorTagReference", params: { referencenumber: tenancy_ref })
        result = JSON.parse(response.body)['results'].first

        tenancy = FAKE_DETAILS.clone.tap do |details|
          tenant = result.fetch('ListOfTenants').select { |tenant| tenant.fetch('personNumber') == '1' }.first
          address = result.fetch('ListOfAddresses').first

          details[:ref] = result.fetch('tagReferenceNumber')
          details[:current_balance] = result.fetch('currentBalance')
          details[:type] = result.fetch('tenure')

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

        if Rails.env.staging?
          Hackney::Income::Anonymizer.anonymize_tenancy(tenancy: tenancy)
        else
          tenancy
        end
      end

      def get_tenancies_in_arrears
        response = RestClient.get("#{@api_host}/v1/Accounts/GetallTenancyinArreasAccountDetails")
        tenancies = JSON.parse(response.body)['results']

        tenancy_list = tenancies.map do |tenancy|
          primary_tenant = tenancy.fetch('ListOfTenants').select { |tenant| tenant.fetch('personNumber') == '1' }.first

          unless primary_tenant
            Rails.logger.warn("Tenancy \"#{tenancy.fetch('tagReferenceNumber')}\" has no appropriate contact")
            next
          end

          {
            primary_contact: {
              first_name: primary_tenant.fetch('forename'),
              last_name: primary_tenant.fetch('surname'),
              title: primary_tenant.fetch('title')
            },
            address_1: tenancy.fetch('ListOfAddresses').first.fetch('shortAddress'),
            post_code: tenancy.fetch('ListOfAddresses').first.fetch('postCode'),
            tenancy_ref: tenancy.fetch('tagReferenceNumber'),
            current_balance: tenancy.fetch('currentBalance').to_s
          }
        end.compact

        if Rails.env.staging?
          tenancy_list.each do |tenancy|
            Hackney::Income::Anonymizer.anonymize_tenancy_list_item(tenancy: tenancy)
          end
        else
          tenancy_list
        end
      end

      private

      FAKE_DETAILS = {
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
