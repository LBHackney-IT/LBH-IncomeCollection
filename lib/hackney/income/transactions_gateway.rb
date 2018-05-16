module Hackney
  module Income
    class TransactionsGateway
      def initialize(api_host:)
        @api_host = api_host
      end

      def transactions_for(tenancy_ref:)
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
    end
  end
end
