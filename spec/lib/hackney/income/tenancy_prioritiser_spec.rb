require 'rails_helper'

describe Hackney::Income::TenancyPrioritiser do
  let(:tenancy) { example_tenancy }
  let(:transactions) { [example_transaction] }

  let(:subject) { described_class.new(tenancy: tenancy, transactions: transactions) }

  context 'when assigning a priority band to a case' do
    it 'passes the tenancy and transactions to the band assignment' do
      expect_any_instance_of(Hackney::Income::TenancyPrioritiser::Band).to receive(:execute).with(
        criteria: instance_of(Hackney::Income::TenancyPrioritiser::Criteria)
      )

      subject.assign_priority_band
    end
  end
end
