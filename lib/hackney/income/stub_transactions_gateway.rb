module Hackney
  module Income
    class StubTransactionsGateway
      def initialize(api_host: nil, api_key: nil, include_developer_data: nil); end

      def transactions_for(tenancy_ref:)
        [{
          id: '123-456-789',
          timestamp: Date.new(2017, 1, 1),
          tenancy_ref: '3456789',
          description: 'Total Rent',
          value: 500.00,
          type: 'RNT'
        }, {
          id: '123-456-789',
          timestamp: Date.new(2018, 1, 1),
          tenancy_ref: '3456789',
          description: 'Rent Payment',
          value: -50.00,
          type: 'RPY'
        }, {
          id: '123-456-789',
          timestamp: Date.new(2015, 1, 1),
          tenancy_ref: '3456789',
          description: 'Rent Payment',
          value: -100.00,
          type: 'RPY'
        }]
      end
    end
  end
end
