require 'rails_helper'

describe TransactionsHelper do
  context '#from_last_four_weeks' do
    subject { helper.from_last_four_weeks(transactions) }

    context 'when given no transactions' do
      let(:transactions) { [] }
      it { is_expected.to eq([]) }
    end

    context 'when given a list of transactions in the last week' do
      let(:transactions) do
        [
          { timestamp: Date.today.midnight },
          { timestamp: Date.today.midnight - 1.day },
          { timestamp: Date.today.midnight - 3.days },
          { timestamp: Date.today.midnight - 7.days }
        ]
      end

      it { is_expected.to eq(transactions) }
    end

    context 'when given a list of transactions from the last few months' do
      let(:valid_transactions) do
        [
          { timestamp: Date.today - 1.week },
          { timestamp: Date.today - 2.weeks },
          { timestamp: Date.today - 4.weeks },
          { timestamp: Date.today.monday - 4.weeks },
          { timestamp: Date.today - 3.week }
        ]
      end

      let(:invalid_transactions) do
        [
          { timestamp: Date.today - 5.week }
        ]
      end

      let(:transactions) do
        (valid_transactions + invalid_transactions).shuffle
      end

      it 'should only return those from the last four weeks, starting Monday' do
        expect(subject).to all(be_in(valid_transactions))
      end
    end
  end
end
