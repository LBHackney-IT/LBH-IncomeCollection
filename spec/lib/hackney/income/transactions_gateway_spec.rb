describe Hackney::Income::TransactionsGateway do
  let(:transaction_gateway) { described_class.new(api_host: 'https://example.com/api') }
  let(:transaction_endpoint) { 'https://example.com/api/v1/tenancies/000123/01/payments' }

  subject { transaction_gateway.transactions_for(tenancy_ref: '000123/01') }
  alias_method :get_transactions, :subject

  context 'when retrieving all transactions for a tenancy with some' do
    before do
      stub_request(:get, transaction_endpoint)
        .to_return(body: {
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
      stub_request(:get, transaction_endpoint)
        .to_return(body: { results: [] }.to_json)
    end

    it 'should include no transactions' do
      expect(subject).to be_empty
    end
  end

  context 'when retrieving all transactions for a developer tenancy' do
    let(:transaction_gateway) { described_class.new(api_host: 'https://example.com/api', include_developer_data: true) }
    subject { transaction_gateway.transactions_for(tenancy_ref: '0000001/FAKE') }

    it 'should return fake transactions' do
      expect(subject).to_not be_empty
    end
  end
end
