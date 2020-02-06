require 'rails_helper'

describe TransactionsHelper do
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
      let(:transactions) do
        Hackney::Income::Timeline.build(
          tenancy_ref: 'NOT_IMPORTANT',
          current_balance: 100,
          transactions: [
            { timestamp: Time.zone.parse('29/01/2019'), value: 10 },
            { timestamp: Time.zone.parse('21/01/2019'), value: 10 },
            { timestamp: Time.zone.parse('14/01/2019'), value: 10 },
            { timestamp: Time.zone.parse('07/01/2019'), value: 10 }
          ],
          actions: []
        )
      end

      before do
        Timecop.freeze('01/06/2019')
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
