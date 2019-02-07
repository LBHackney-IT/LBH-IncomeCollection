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
          { week: generate_date_range(0) },
          { week: generate_date_range(1) },
          { week: generate_date_range(2) },
          { week: generate_date_range(3) },
          { week: generate_date_range(4) }
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

  context 'when calling from_last_year' do
    let(:transactions) { [] }
    subject { helper.from_last_year_as_json(transactions) }

    it 'returns empty sting' do
      expect(subject).to eq('[]')
    end

    context 'where there are a number of transactions' do
      let(:transactions_from_server) do
        [
          { timestamp: Date.parse('29/01/2019'), value: 10 },
          { timestamp: Date.parse('21/01/2019'), value: 10 },
          { timestamp: Date.parse('14/01/2019'), value: 10 },
          { timestamp: Date.parse('07/01/2019'), value: 10 }
        ]
      end
      let(:transactions) do
        Hackney::Income::TransactionsBalanceCalculator.new.organise_with_final_balances_by_week(
          current_balance: 100,
          transactions: transactions_from_server
        )
      end

      it 'returns a hash of transactions' do
        expect(subject).to eq('[{"description":"Summary for 28 Jan - 3 Feb 2019","date":"2019-02-03","displayValue":"Incoming: £0.00, Outgoing: £10.00","finalBalance":100},{"description":"Summary for 21 - 27 Jan 2019","date":"2019-01-27","displayValue":"Incoming: £0.00, Outgoing: £10.00","finalBalance":90},{"description":"Summary for 14 - 20 Jan 2019","date":"2019-01-20","displayValue":"Incoming: £0.00, Outgoing: £10.00","finalBalance":80},{"description":"Summary for 7 - 13 Jan 2019","date":"2019-01-13","displayValue":"Incoming: £0.00, Outgoing: £10.00","finalBalance":70}]')
      end
    end
  end
end

def generate_date_range(weeks_ago)
  (Date.today - weeks_ago.week).monday..(Date.today - weeks_ago.week).sunday
end
