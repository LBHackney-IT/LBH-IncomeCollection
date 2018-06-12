require 'rails_helper'

describe Hackney::Income::TenancyPrioritiser do
  let(:tenancy) { example_tenancy }
  let(:transactions) { [example_transaction] }
  let(:weightings) { Hackney::Income::TenancyPrioritiser::PriorityWeightings.new }

  let(:subject) { described_class.new(tenancy: tenancy, transactions: transactions, weightings: weightings) }

  context 'when assigning a priority band to a case' do
    it 'passes the criteria to the band assignment' do
      expect_any_instance_of(Hackney::Income::TenancyPrioritiser::Band).to receive(:execute).with(
        criteria: instance_of(Hackney::Income::TenancyPrioritiser::Criteria)
      )

      subject.assign_priority_band
    end
  end

  context 'when assigning a priority score to a case' do
    it 'passes the criteria to the score assignment' do
      expect_any_instance_of(Hackney::Income::TenancyPrioritiser::Score).to receive(:execute)

      subject.assign_priority_score
    end
  end
end
