require 'rails_helper'

describe Hackney::Income::TenancyPrioritiser do
  let(:tenancy) do
    example_tenancy(
      agreements:
      [
        example_agreement
      ],
      arrears_actions:
      [
        example_arrears_action
      ]
    )
  end
  let(:transactions) do
    [
      example_transaction,
      example_transaction,
      example_transaction
    ]
  end

  subject { described_class.new }

  context 'assigning a tenancy to the red band' do
    it 'happens when balance is greater than £1050' do
      tenancy[:current_balance] = '1050.00'
      subject.assign_priority_band(tenancy: tenancy, transactions: transactions)

      assert_red
    end

    it 'happens when a court ordered repayment agreement is broken' do
      tenancy[:agreements] = [example_agreement(status: 'breached', type: 'court_ordered')]
      subject.assign_priority_band(tenancy: tenancy, transactions: transactions)

      assert_red
    end

    # FIXME: I think we should probably defensively filter agreements > 3 years old
    it 'happens when more than two agreements have been breached in the last three years' do
      tenancy[:agreements] = [
        example_agreement(status: 'breached', type: 'informal'),
        example_agreement(status: 'breached', type: 'informal'),
        example_agreement(status: 'breached', type: 'informal')
      ]

      subject.assign_priority_band(tenancy: tenancy, transactions: transactions)

      assert_red
    end

    it 'happens when debt age is greater than 30 weeks' do
      transactions = [example_transaction(timestamp: Time.now - 31.weeks)]
      subject.assign_priority_band(tenancy: tenancy, transactions: transactions)

      assert_red
    end

    it 'happens when a valid nosp is present and no payment has been received in 28 days' do
      tenancy[:arrears_actions] = [example_arrears_action(type: 'nosp')]
      subject.assign_priority_band(tenancy: tenancy, transactions: {})

      assert_red
    end

    context 'when payment pattern is erratic' do
      it 'is assigned red because because payment pattern delta greater than three' do
        transactions = [
          example_transaction(timestamp: Time.now + 15.days),
          example_transaction(timestamp: Time.now + 5.days),
          example_transaction(timestamp: Time.now)
        ]
        subject.assign_priority_band(tenancy: tenancy, transactions: transactions)
        assert_red
      end

      it 'is assigned red because because payment pattern delta less than negative three' do
        transactions = [
          example_transaction(timestamp: Time.now - 15.days),
          example_transaction(timestamp: Time.now - 5.days),
          example_transaction(timestamp: Time.now)
        ]
        subject.assign_priority_band(tenancy: tenancy, transactions: transactions)
        assert_red
      end

      it 'is assigned red because because payment amount delta that is negative' do
        transactions = [
          example_transaction(value: -5.00),
          example_transaction(value: -15.00),
          example_transaction(value: -15.00)
        ]
        subject.assign_priority_band(tenancy: tenancy, transactions: transactions)
        assert_red
      end
    end

    context 'assigning a tenancy to the amber band' do
      it 'happens when balance is greater than £350' do
        tenancy[:current_balance] = '350.00'
        subject.assign_priority_band(tenancy: tenancy, transactions: transactions)

        assert_amber
      end

      it 'happens when debt age is greater than 15 weeks' do
        transactions = [example_transaction(timestamp: Time.now - 16.weeks)]
        subject.assign_priority_band(tenancy: tenancy, transactions: transactions)

        assert_amber
      end

      it 'happens when a a valid nosp was served within the last 28 days' do
        tenancy[:arrears_actions] = [example_arrears_action(type: 'nosp')]
        subject.assign_priority_band(tenancy: tenancy, transactions: transactions)

        assert_amber
      end

      it 'happens when there is a live agreement and previous agreements have been broken' do
        tenancy[:agreements] = [
          example_agreement(status: 'breached', type: 'informal'),
          example_agreement(status: 'breached', type: 'informal'),
          example_agreement(status: 'active', type: 'informal')
        ]
        subject.assign_priority_band(tenancy: tenancy, transactions: transactions)

        assert_amber
      end
    end

    context 'assigning a tenancy to the green band' do
      it 'is otherwise green' do
        subject.assign_priority_band(tenancy: tenancy, transactions: transactions)

        assert_green
      end
    end
  end

  private

  def assert_red
    expect(tenancy.fetch(:priority_band)).to eq('Red')
  end

  def assert_amber
    expect(tenancy.fetch(:priority_band)).to eq('Amber')
  end

  def assert_green
    expect(tenancy.fetch(:priority_band)).to eq('Green')
  end
end
