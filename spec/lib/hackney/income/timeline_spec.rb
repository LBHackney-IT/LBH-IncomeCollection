require 'rails_helper'

describe Hackney::Income::Timeline do
  let(:timeline) { described_class.new }
  let(:tenancy_ref) { 'NOT_IMPORTANT' }
  let(:transaction_comment) { 'Something something' }
  let(:action_comment) { 'Something else and something else' }
  let(:action_user) { Faker::Name.name }
  let(:action_code) { Hackney::Income::ActionDiaryEntryCodes.all_code_options.sample[:code] }

  describe '#execute' do
    let(:options) do
      {
        tenancy_ref: tenancy_ref,
        current_balance: current_balance,
        actions: actions,
        transactions: transactions
      }
    end
    let(:current_balance) { 12_000.0 }
    let(:actions) { build_actions }
    let(:transactions) { build_transactions }

    it 'returns an array of arrays' do
      expect(timeline.execute(options)).to eq(expected_array)
    end

    it 'uses "YYYY-WeekNum" for keys of summaries' do
      array = timeline.execute(options)

      expect(array[0][0]).to eq('2019-02')
    end

    it 'orders the array in most recent first' do
      array = timeline.execute(options)

      expect(array[0][0]).to eq('2019-02')
      expect(array[1][0]).to eq('2019-01')
    end

    context 'when looking at the summary object' do
      let(:summary) { timeline.execute(options)[1][1] }

      it 'contains a list of line items' do
        expect(summary[:list].first.keys).to match_array(
          %i[date code balance comment value user transaction action]
        )
      end

      it 'has a date range' do
        expect(summary[:date_range].first).to be_a(Time)
        expect(summary[:date_range].last).to be_a(Time)
      end

      it 'contains the overall incoming transactions within the week' do
        expected_sum = summary[:list].reduce(0) do |acc, item|
          acc += item[:value] if item[:value].negative?
          acc
        end

        expect(summary[:incoming]).to eq(expected_sum)
      end

      it 'contains the overall outgoing transactions within the week' do
        expected_sum = summary[:list].reduce(0) do |acc, item|
          acc += item[:value] if item[:value].positive?
          acc
        end

        expect(summary[:outgoing]).to eq(expected_sum)
      end

      it 'has a count for number of actions' do
        expect(summary[:num_of_actions]).to eq(2)
      end

      it 'has a count for number of transactions' do
        expect(summary[:num_of_actions]).to eq(2)
      end
    end

    context 'when looking at the top (most recent) summary' do
      let(:summary) { timeline.execute(options)[0][1] }

      it 'contains the current account balance' do
        expect(summary[:balance]).to eq(current_balance)
      end
    end

    context 'when looking at the second most recent summary' do
      let(:previous_summary) { timeline.execute(options)[0][1] }
      let(:summary) { timeline.execute(options)[1][1] }
      let(:transactions_in_week) { summary[:list].select { |i| i[:transaction] } }

      it 'the balance is the start of the later week' do
        expect(summary[:balance]).to eq(previous_summary[:list].last[:balance])
      end

      it 'calculates the correct oldest line item balance' do
        total = transactions_in_week.sum { |i| i[:value] }

        expect(summary[:list].last[:balance]).to eq(summary[:balance] - total)
      end
    end

    context 'when looking at a line item' do
      let(:first_line_item) { timeline.execute(options)[0][1][:list].first }
      let(:last_line_item) { timeline.execute(options)[0][1][:list].last }

      it 'does not use the original transaction balance' do
        expect(transactions.last[:balance]).to be_nil
        expect(first_line_item[:balance]).not_to be_nil
      end

      it 'does not use the original action balance' do
        expect(last_line_item[:balance]).not_to eq(actions.last[:balance])
      end

      it 'contains a flag to let the UI know when type it is' do
        expect(first_line_item[:action]).to eq(false)
        expect(first_line_item[:transaction]).to eq(true)

        expect(last_line_item[:action]).to eq(true)
        expect(last_line_item[:transaction]).to eq(false)
      end
    end

    context 'when looking at transactions' do
      let(:transaction_line_items) do
        timeline.execute(options).reduce([]) do |memo, array|
          memo += array[1][:list].select { |item| item[:transaction] }
          memo
        end
      end

      context 'and checking their balances' do
        it "the lastest transaction's balance is (current_balance - transaction_value)" do
          first_line_item = transaction_line_items.first
          expect(first_line_item[:balance]).to eq(current_balance - first_line_item[:value])
        end

        it "the second latest transaction's balance is (first_transaction_balance - transaction_value)" do
          first_line_item = transaction_line_items.first
          second_line_item = transaction_line_items.second
          expect(second_line_item[:balance]).to eq(first_line_item[:balance] - second_line_item[:value])
        end

        it "the third latest transaction's balance is (second_line_item - transaction_value)" do
          second_line_item = transaction_line_items.second
          third_line_item = transaction_line_items.third
          expect(third_line_item[:balance]).to eq(second_line_item[:balance] - third_line_item[:value])
        end
      end
    end

    context 'when an action diary entry has a different balance than we expect' do
      let(:actions) do
        [
          {
            balance: 1_000_000,
            code: action_code,
            type: nil,
            date: Time.zone.parse('08/01/2019'),
            display_date: nil,
            comment: action_comment,
            universal_housing_username: action_user
          }
        ]
      end

      before do
        expect(Raven).to receive(:capture_exception).with(an_instance_of(RuntimeError))
      end

      it 'notifies Sentry via Raven' do
        timeline.execute(options)
      end
    end
  end

  def expected_array
    week_one_start = Time.zone.parse('07/01/2019').beginning_of_week
    week_one_end = week_one_start.end_of_week
    week_one_range = week_one_start..week_one_end

    week_two_start = Time.zone.parse('14/01/2019').beginning_of_week
    week_two_end = week_two_start.end_of_week
    week_two_range = week_two_start..week_two_end

    [
      [
        '2019-02', {
          list: [
            {
              date: transactions[3][:timestamp],
              code: nil,
              balance: current_balance - transactions.last(1).sum { |t| t[:value] },
              comment: transactions[3][:description],
              value: transactions[3][:value],
              user: nil,
              transaction: true,
              action: false
            },
            {
              date: transactions[2][:timestamp],
              code: nil,
              balance: current_balance - transactions.last(2).sum { |t| t[:value] },
              comment: transactions[2][:description],
              value: transactions[2][:value],
              user: nil,
              transaction: true,
              action: false
            },
            {
              date: actions[2][:date],
              code: actions[2][:code],
              balance: current_balance - transactions.last(2).sum { |t| t[:value] },
              action_diary_balance: nil,
              comment: actions[2][:comment],
              value: 0,
              user: actions[2][:universal_housing_username],
              transaction: false,
              action: true
            }
          ],
          date_range: week_two_range,
          balance: current_balance,
          incoming: -125.0,
          outgoing: 0,
          num_of_actions: 1,
          num_of_transactions: 2
        }
      ],
      [
        '2019-01', {
          list: [
            {
              date: transactions[1][:timestamp],
              code: nil,
              balance: current_balance - transactions.last(3).sum { |t| t[:value] },
              comment: transactions[1][:description],
              value: transactions[1][:value],
              user: nil,
              transaction: true,
              action: false
            },
            {
              date: actions[1][:date],
              code: actions[1][:code],
              balance: current_balance - transactions.last(3).sum { |t| t[:value] },
              action_diary_balance: nil,
              comment: actions[1][:comment],
              value: 0,
              user: actions[1][:universal_housing_username],
              transaction: false,
              action: true
            },
            {
              date: transactions[0][:timestamp],
              code: nil,
              balance: current_balance - transactions.last(4).sum { |t| t[:value] },
              comment: transactions[0][:description],
              value: transactions[0][:value],
              user: nil,
              transaction: true,
              action: false
            },
            {
              date: actions[0][:date],
              code: actions[0][:code],
              balance: current_balance - transactions.last(4).sum { |t| t[:value] },
              action_diary_balance: nil,
              comment: actions[0][:comment],
              value: 0,
              user: actions[0][:universal_housing_username],
              transaction: false,
              action: true
            }
          ],
          date_range: week_one_range,
          balance: current_balance - transactions.last(2).sum { |t| t[:value] },
          incoming: -50.0,
          outgoing: 100.0,
          num_of_actions: 2,
          num_of_transactions: 2
        }
      ]
    ]
  end

  def build_actions
    [
      {
        balance: nil,
        code: action_code,
        type: nil,
        date: Time.zone.parse('08/01/2019'),
        display_date: nil,
        comment: action_comment,
        universal_housing_username: action_user
      },
      {
        balance: nil,
        code: action_code,
        type: nil,
        date: Time.zone.parse('10/01/2019'),
        display_date: nil,
        comment: action_comment,
        universal_housing_username: action_user
      },
      {
        balance: nil,
        code: action_code,
        type: nil,
        date: Time.zone.parse('15/01/2019'),
        display_date: nil,
        comment: action_comment,
        universal_housing_username: action_user
      }
    ]
  end

  def build_transactions
    [
      {
        id: Faker::Number.number,
        timestamp: Time.zone.parse('09/01/2019'),
        tenancy_ref: tenancy_ref,
        description: transaction_comment,
        value: 100.00
      },
      {
        id: Faker::Number.number,
        timestamp: Time.zone.parse('11/01/2019'),
        tenancy_ref: tenancy_ref,
        description: transaction_comment,
        value: -50.00
      },
      {
        id: Faker::Number.number,
        timestamp: Time.zone.parse('16/01/2019'),
        tenancy_ref: tenancy_ref,
        description: transaction_comment,
        value: -50.00
      },
      {
        id: Faker::Number.number,
        timestamp: Time.zone.parse('16/01/2019'),
        tenancy_ref: tenancy_ref,
        description: transaction_comment,
        value: -75.00
      }
    ]
  end
end
