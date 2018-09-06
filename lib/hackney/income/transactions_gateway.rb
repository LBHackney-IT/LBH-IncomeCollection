module Hackney
  module Income
    class TransactionsGateway
      def initialize(api_host:, api_key:, include_developer_data: false)
        @api_host = api_host
        @api_key = api_key
        @include_developer_data = include_developer_data
      end

      def transactions_for(tenancy_ref:)
        if @include_developer_data && DEVELOPER_TENANCY_REFS.include?(tenancy_ref)
          return FAKE_TRANSACTIONS
        end
        
        uri = URI("#{@api_host}/tenancies/#{ERB::Util.url_encode(tenancy_ref)}/payments")
        req = Net::HTTP::Get.new(uri)
        req['X-Api-Key'] = @api_key

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

        transactions = JSON.parse(res.body).fetch('payment_transactions')
        transactions.map do |transaction|
          {
            id: transaction.fetch('property_ref'),
            timestamp: Time.parse(transaction.fetch('date')),
            tenancy_ref: tenancy_ref,
            description: 'Fake description',
            value: tidy(transaction.fetch('amount')),
            type: transaction.fetch('type')
          }
        end
      end

      def tidy(amount)
        amount.delete('¤').tr('(', '-').delete(')').to_f
      end

      DEVELOPER_TENANCY_REFS = %w[0000001/FAKE].freeze
      FAKE_TRANSACTIONS = [{
        id: '123-456-789',
        timestamp: Time.new(2017, 1, 1, 0, 0, 0),
        tenancy_ref: '3456789',
        description: 'Total Rent',
        value: 500.00,
        type: 'RNT'
      }, {
        id: '123-456-789',
        timestamp: Time.new(2018, 1, 1, 0, 0, 0),
        tenancy_ref: '3456789',
        description: 'Rent Payment',
        value: -50.00,
        type: 'RPY'
      }, {
        id: '123-456-789',
        timestamp: Time.new(2015, 1, 1, 0, 0, 0),
        tenancy_ref: '3456789',
        description: 'Rent Payment',
        value: -100.00,
        type: 'RPY'
      }].freeze

      private_constant :DEVELOPER_TENANCY_REFS
      private_constant :FAKE_TRANSACTIONS
    end
  end
end
