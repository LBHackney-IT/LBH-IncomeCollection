describe Hackney::Income::TransactionsGateway do
  let(:transaction_gateway) { described_class.new(api_host: 'https://example.com') }
  let(:transaction_endpoint) { 'https://example.com/v1/Transactions?tagReference=000123%2F01' }

  subject { transaction_gateway.transactions_for(tenancy_ref: '000123/01') }
  alias_method :get_transactions, :subject

  context 'when retrieving all transactions for a tenancy with some' do
    before do
      stub_request(:get, transaction_endpoint).
        to_return(body: {
          results: [{
            tagReference: '000123/01',
            propertyReference: '00012345',
            transactionSid: nil,
            houseReference: '000123',
            transactionType: 'RNT',
            postDate: '2018-03-26T00:00:00',
            realValue: 133.75,
            transactionID: '0d4911d2-ce30-e811-1234-70106faa6a11',
            debDesc: 'Total Rent'
          }]
        }.to_json)
    end

    it 'should call the appropriate endpoint' do
      get_transactions
      assert_requested :get, transaction_endpoint
    end

    it 'should include a transaction' do
      expect(subject).to include(
        id: '0d4911d2-ce30-e811-1234-70106faa6a11',
        timestamp: Time.new(2018, 3, 26, 0, 0, 0),
        tenancy_ref: '000123/01',
        description: 'Total Rent',
        value: 133.75,
        type: 'RNT'
      )
    end
  end

  context 'when retrieving all transactions for a tenancy with none' do
    before do
      stub_request(:get, transaction_endpoint).
        to_return(body: { results: [] }.to_json)
    end

    it 'should include no transactions' do
      expect(subject).to be_empty
    end
  end
end
