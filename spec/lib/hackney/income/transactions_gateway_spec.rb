require 'rails_helper'

describe Hackney::Income::TransactionsGateway do
  let(:transaction_gateway) { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }
  let(:transaction_endpoint) { 'https://example.com/api/v1/tenancies/000123%2F01/payments' }

  let(:tenancy_ref) { '000123/01' }
  subject { transaction_gateway.transactions_for(tenancy_ref: tenancy_ref) }
  alias_method :get_transactions, :subject

  context 'when the api returns an error' do
    before do
      stub_request(:get, transaction_endpoint)
      .to_return(status: 500)
    end

    it 'should raise a IncomeApiError' do
      expect { subject }.to raise_error(Exceptions::IncomeApiError, "[Income API error: Received 500 response] when trying to get transactions_for with tenancy_ref '#{tenancy_ref}'")
    end
  end

  context 'when retrieving all transactions for a tenancy with some' do
    before do
      stub_request(:get, transaction_endpoint)
        .to_return(body: {
          payment_transactions: [{
            ref: '00012345',
            transactionSid: nil,
            property_ref: '000123',
            type: 'RNT',
            date: '2018-03-26T00:00:00',
            amount: '¤133.75',
            transactionID: '0d4911d2-ce30-e811-1234-70106faa6a11',
            description: 'Total Rent'
          }]
        }.to_json)
    end

    it 'should call the appropriate endpoint' do
      get_transactions
      assert_requested :get, transaction_endpoint
    end

    it 'should include a transaction' do
      expect(subject).to include(
        id: '000123',
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
        .to_return(body: { payment_transactions: [] }.to_json)
    end

    it 'should include no transactions' do
      expect(subject).to be_empty
    end
  end

  context 'when retrieving all transactions for a developer tenancy' do
    let(:transaction_gateway) { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton', include_developer_data: true) }
    subject { transaction_gateway.transactions_for(tenancy_ref: '0000001/FAKE') }

    it 'should return fake transactions' do
      expect(subject).to_not be_empty
    end
  end
end
