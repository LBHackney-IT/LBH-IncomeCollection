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

  subject { described_class.new(tenancy: tenancy, transactions: transactions).assign_priority_band }

  context 'assigning a tenancy to the red band' do
    context 'happens when balance is greater than £1050' do
      let(:tenancy) { example_tenancy(current_balance: '1050.00') }

      it { is_expected.to eq(:red) }
    end

    context 'happens when a court ordered repayment agreement is broken' do
      let(:tenancy) do
        example_tenancy(
          agreements:
          [
            example_agreement(status: 'breached', type: 'court_ordered')
          ]
        )
      end

      it { is_expected.to eq(:red) }
    end

    # FIXME: I think we should probably defensively filter agreements > 3 years old
    context 'happens when more than two agreements have been breached in the last three years' do
      let(:tenancy) do
        example_tenancy(
          agreements:
          [
            example_agreement(status: 'breached', type: 'informal'),
            example_agreement(status: 'breached', type: 'informal'),
            example_agreement(status: 'breached', type: 'informal')
          ]
        )
      end

      it { is_expected.to eq(:red) }
    end

    context 'happens when debt age is greater than 30 weeks' do
      let(:transactions) { [example_transaction(timestamp: Time.now - 31.weeks)] }

      it { is_expected.to eq(:red) }
    end

    context 'happens when a valid nosp is present and no payment has been received in 28 days' do
      let(:transactions) { [example_transaction(timestamp: Time.now - 30.days)] }
      let(:tenancy) do
        example_tenancy(
          arrears_actions:
          [
            example_arrears_action(type: 'nosp')
          ]
        )
      end

      it { is_expected.to eq(:red) }
    end

    context 'happens when a valid nosp is present and no payment has ever been received' do
      let(:tenancy) do
        example_tenancy(
          arrears_actions:
          [
            example_arrears_action(type: 'nosp')
          ]
        )
      end

      let(:transactions) { [] }

      it { is_expected.to eq(:red) }
    end

    context 'when payment pattern is erratic' do
      context 'is assigned red because because payment pattern delta greater than three' do
        let(:transactions) do
          [
            example_transaction(timestamp: Time.now + 15.days),
            example_transaction(timestamp: Time.now + 5.days),
            example_transaction(timestamp: Time.now)
          ]
        end

        it { is_expected.to eq(:red) }
      end

      context 'is assigned red because because payment pattern delta less than negative three' do
        let(:transactions) do
          [
            example_transaction(timestamp: Time.now - 15.days),
            example_transaction(timestamp: Time.now - 5.days),
            example_transaction(timestamp: Time.now)
          ]
        end

        it { is_expected.to eq(:red) }
      end

      context 'is assigned red because because payment amount delta that is negative' do
        let(:transactions) do
          [
            example_transaction(value: -5.00),
            example_transaction(value: -15.00),
            example_transaction(value: -15.00)
          ]
        end

        it { is_expected.to eq(:red) }
      end
    end

    context 'assigning a tenancy to the amber band' do
      context 'happens when balance is greater than £350' do
        let(:tenancy) { example_tenancy(current_balance: '350.00') }

        it { is_expected.to eq(:amber) }
      end

      context 'happens when debt age is greater than 15 weeks' do
        let(:transactions) { [example_transaction(timestamp: Time.now - 16.weeks)] }

        it { is_expected.to eq(:amber) }
      end

      context 'happens when a a valid nosp was served within the last 28 days' do
        let(:tenancy) do
          example_tenancy(
            arrears_actions:
            [
              example_arrears_action(type: 'nosp')
            ]
          )
        end

        it { is_expected.to eq(:amber) }
      end

      context 'happens when there is a live agreement and previous agreements have been broken' do
        let(:tenancy) do
          example_tenancy(
            agreements:
            [
              example_agreement(status: 'breached', type: 'informal'),
              example_agreement(status: 'breached', type: 'informal'),
              example_agreement(status: 'active', type: 'informal')
            ]
          )
        end

        it { is_expected.to eq(:amber) }
      end
    end

    context 'assigning a tenancy to the green band' do
      context 'is otherwise green' do
        it { is_expected.to eq(:green) }
      end
    end
  end
end
