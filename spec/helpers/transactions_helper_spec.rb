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
          { week: Date.today.monday..Date.today.sunday },
          { week: (Date.today - 1.week).monday..(Date.today - 1.week).sunday },
          { week: (Date.today - 2.week).monday..(Date.today - 2.week).sunday },
          { week: (Date.today - 3.week).monday..(Date.today - 3.week).sunday },
          { week: (Date.today - 4.week).monday..(Date.today - 4.week).sunday }
        ]
      end

      it { is_expected.to eq(transactions) }
    end

    context 'when given a list of transactions from the last few months' do
      let(:valid_transactions) do
        [
          { date: Date.today - 1.week },
          { date: Date.today - 2.weeks },
          { date: Date.today - 4.weeks },
          { date: Date.today.monday - 4.weeks },
          { date: Date.today - 3.week }
        ]
      end

      let(:invalid_transactions) do
        [
          { date: Date.today - 5.week }
        ]
      end

      let(:transactions) do
        (valid_transactions + invalid_transactions).shuffle
      end
    end
  end

  context '#class_for_value' do
    subject { helper.class_for_value(value) }

    context 'when given positive value' do
      let(:value) { 10 }
      it { is_expected.to eq('positive') }
    end

    context 'when given negative value' do
      let(:value) { -10 }
      it { is_expected.to eq('negative') }
    end
  end
end
