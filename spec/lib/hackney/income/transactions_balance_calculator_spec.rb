require 'rails_helper'

describe Hackney::Income::TransactionsBalanceCalculator do
  let(:current_balance) { 30 }
  let(:base_time) { Date.current }

  subject do
    described_class.new.organise_with_final_balances(
      current_balance: current_balance,
      transactions: transactions_from_server
    )
  end

  context 'given tenant never pays' do
    let(:transactions_from_server) do
      [
        { timestamp: Date.parse('29/01/2019'), value: 10 },
        { timestamp: Date.parse('21/01/2019'), value: 10 },
        { timestamp: Date.parse('14/01/2019'), value: 10 },
        { timestamp: Date.parse('07/01/2019'), value: 10 }
      ]
    end

    it 'should determine the final balance for each transaction summary week' do
      final_balances = subject.map { |t| t.fetch(:final_balance) }

      expect(final_balances).to eq([30, 20, 10, 0])
    end
  end

  context 'given tenant always pays and there is no rent' do
    let(:transactions_from_server) do
      [
        { timestamp: Date.parse('29/01/2019'), value: -10 },
        { timestamp: Date.parse('21/01/2019'), value: -10 },
        { timestamp: Date.parse('14/01/2019'), value: -10 },
        { timestamp: Date.parse('07/01/2019'), value: -10 }
      ]
    end

    it 'should determine the final balance for each transaction summary week' do
      final_balances = subject.map { |t| t.fetch(:final_balance) }

      expect(final_balances).to eq([30, 40, 50, 60])
    end
  end

  context 'given tenant sometimes pays' do
    let(:transactions_from_server) do
      [
        { timestamp: Date.parse('29/01/2019'), value: -30 },
        { timestamp: Date.parse('28/01/2019'), value: 20 },
        { timestamp: Date.parse('21/01/2019'), value: 10 },
        { timestamp: Date.parse('17/01/2019'), value: -30 },
        { timestamp: Date.parse('14/01/2019'), value: 20 },
        { timestamp: Date.parse('07/01/2019'), value: 20 }
      ]
    end

    it 'should determine the final balance for each transaction summary week' do
      final_balances = subject.map { |t| t.fetch(:final_balance) }

      expect(final_balances).to eq([30, 20, 30, 10])
    end

    it 'should return the transactions grouped by week' do
      dates = subject.map { |t| t.fetch(:week) }
      expect(dates).to eq([
        Date.parse('28/01/2019')..Date.parse('03/02/2019'),
        Date.parse('21/01/2019')..Date.parse('27/01/2019'),
        Date.parse('14/01/2019')..Date.parse('20/01/2019'),
        Date.parse('07/01/2019')..Date.parse('13/01/2019')
      ])
    end

    it 'should return a sum of incoming transactions' do
      incoming = subject.map { |t| t.fetch(:incoming) }

      expect(incoming).to eq([-30, 0, -30, 0])
    end

    it 'should return a sum of outgoing transactions' do
      outgoing = subject.map { |t| t.fetch(:outgoing) }

      expect(outgoing).to eq([20, 10, 20, 20])
    end
  end
end
