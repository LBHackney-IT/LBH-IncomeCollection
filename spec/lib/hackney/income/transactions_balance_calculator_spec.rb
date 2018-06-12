require 'rails_helper'

describe Hackney::Income::TransactionsBalanceCalculator do
  let(:current_balance) { Faker::Number.decimal(2).to_f }
  let(:base_time) { Time.now }
  let(:transaction_three) { -Faker::Number.decimal(2).to_f }
  let(:transaction_two) { -Faker::Number.decimal(2).to_f }
  let(:transaction_one) { Faker::Number.decimal(2).to_f }

  let(:shuffled_transactions) do
    [
      { timestamp: base_time - 1.day, value: transaction_three },
      { timestamp: base_time - 2.days, value: transaction_two },
      { timestamp: base_time - 3.days, value: transaction_one }
    ].shuffle
  end

  subject do
    described_class.new.with_final_balances(
      current_balance: current_balance,
      transactions: shuffled_transactions
    )
  end

  it 'should return the transactions in order' do
    dates = subject.map { |t| t.fetch(:timestamp) }
    expect(dates).to eq([base_time - 1.day, base_time - 2.days, base_time - 3.days])
  end

  it 'should determine the final balance for each transaction given' do
    final_balances = subject.map { |t| t.fetch(:final_balance) }
    expect(final_balances).to eq([
      current_balance,
      current_balance - transaction_three,
      current_balance - transaction_three - transaction_two
    ])
  end
end
