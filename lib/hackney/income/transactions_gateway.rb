module Hackney
  module Income
    class TransactionsGateway
      def initialize(api_host:, include_developer_data: false)
        @api_host = api_host
        @include_developer_data = include_developer_data
      end

      def transactions_for(tenancy_ref:)
        if @include_developer_data && DEVELOPER_TENANCY_REFS.include?(tenancy_ref)
          return FAKE_TRANSACTIONS
        end

        response = RestClient.get("#{@api_host}/v1/Transactions", params: { tagReference: tenancy_ref })
        transactions = JSON.parse(response).fetch('results')

        transactions.map do |transaction|
          {
            id: transaction.fetch('transactionID'),
            timestamp: Time.parse(transaction.fetch('postDate')),
            tenancy_ref: transaction.fetch('tagReference'),
            description: transaction.fetch('debDesc'),
            value: transaction.fetch('realValue'),
            type: transaction.fetch('transactionType')
          }
        end
      end

      DEVELOPER_TENANCY_REFS = %w(0000001/FAKE)
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
      }]
    end
  end
end
