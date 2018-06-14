require 'rails_helper'

describe Hackney::Income::TenancyPrioritiser::Criteria do
  let(:tenancy_attributes) { example_tenancy }
  let(:transactions) { [example_transaction] }

  subject { described_class.new(tenancy_attributes, transactions) }

  context '#balance' do
    let(:example_balance) { Faker::Number.decimal(2) }
    let(:tenancy_attributes) { example_tenancy(current_balance: example_balance) }

    its(:balance) { is_expected.to eq(example_balance.to_f) }
  end

  context '#days_since_last_payment' do
    let(:days_since) { Faker::Number.number(2).to_i }
    let(:transactions) { [example_transaction(timestamp: Date.today - days_since.days)] }

    its(:days_since_last_payment) { is_expected.to eq(days_since) }

    context 'when no payment has ever been made' do
      let(:transactions) { [] }
      its(:days_since_last_payment) { is_expected.to eq(nil) }
    end
  end

  context '#number_of_broken_agreements' do
    # FIXME: what type is a breached agreement?
    context 'when there are no broken agreements' do
      its(:number_of_broken_agreements) { is_expected.to eq(0) }
    end

    context 'when there are broken agreements' do
      let(:breached_agreements_count) { 1 + Faker::Number.number(1).to_i }
      let(:other_agreements_count) { 1 + Faker::Number.number(1).to_i }
      let(:breached_agreements) { breached_agreements_count.times.to_a.map { { status: 'breached' } } }
      let(:other_agreements) { other_agreements_count.times.to_a.map { { status: 'other' } } }
      let(:tenancy_attributes) { example_tenancy(agreements: breached_agreements + other_agreements) }

      its(:number_of_broken_agreements) { is_expected.to eq(breached_agreements_count) }
    end
  end

  context '#active_agreement' do
    context 'when there are no agreements in place' do
      let(:tenancy_attributes) { example_tenancy(agreements: []) }

      its(:active_agreement?) { is_expected.to eq(false) }
    end

    context 'when there are historic agreements present' do
      let(:terminated_agreement) { example_agreement(status: 'terminated') }
      let(:tenancy_attributes) { example_tenancy(agreements: [terminated_agreement]) }

      its(:active_agreement?) { is_expected.to eq(false) }
    end

    context 'when there is an active agreement' do
      let(:active_agreement) { example_agreement(status: 'active') }
      let(:tenancy_attributes) { example_tenancy(agreements: [active_agreement]) }

      its(:active_agreement?) { is_expected.to eq(true) }
    end
  end

  context '#broken_court_order?' do
    context 'when there are no broken court ordered agreements' do
      its(:broken_court_order?) { is_expected.to eq(false) }
    end

    context 'when there are broken court ordered agreements' do
      # FIXME: what type is a court ordered agreement?
      let(:tenancy_attributes) { example_tenancy(agreements: [{ status: 'breached', type: 'court_ordered' }]) }
      its(:broken_court_order?) { is_expected.to eq(true) }
    end

    context 'when there are broken informal agreements' do
      # FIXME: what type is an informal agreement?
      let(:tenancy_attributes) { example_tenancy(agreements: [{ status: 'breached', type: 'informal' }]) }
      its(:broken_court_order?) { is_expected.to eq(false) }
    end

    context 'when there are active agreements' do
      let(:tenancy_attributes) { example_tenancy(agreements: [{ status: 'active' }]) }
      its(:broken_court_order?) { is_expected.to eq(false) }
    end
  end

  context '#valid_nosp?' do
    context 'when a nosp has not been served' do
      its(:nosp_served?) { is_expected.to eq(false) }
    end

    context 'when a nosp has been served' do
      # FIXME: what type is a NOSP arrears action diary event?
      let(:tenancy_attributes) { example_tenancy(arrears_actions: [{ type: 'nosp' }]) }
      its(:nosp_served?) { is_expected.to eq(true) }
    end

    context 'when a nosp was served more than one year ago' do
      # FIXME: leap years? what is the legal definition of a year when serving a NOSP?
      let(:tenancy_attributes) { example_tenancy(arrears_actions: [{ type: 'nosp', date: (Date.today - 366.days).to_time.strftime('%Y-%m-%d') }]) }
      its(:nosp_served?) { is_expected.to eq(false) }
    end
  end

  context '#active_nosp?' do
    context 'when a nosp has not been served' do
      its(:active_nosp?) { is_expected.to eq(false) }
    end

    context 'when a nosp has been served less than 28 days ago, it is active' do
      # FIXME: what type is a NOSP arrears action diary event?
      let(:tenancy_attributes) { example_tenancy(arrears_actions: [{ type: 'nosp' }]) }
      its(:active_nosp?) { is_expected.to eq(true) }
    end

    context 'when a nosp was served more than 28 days ago, it is valid but not active' do
      # FIXME: leap years? what is the legal definition of a year when serving a NOSP?
      let(:tenancy_attributes) { example_tenancy(arrears_actions: [{ type: 'nosp', date: (Date.today - 30.days).to_time.strftime('%Y-%m-%d') }]) }
      its(:nosp_served?) { is_expected.to eq(true) }
      its(:active_nosp?) { is_expected.to eq(false) }
    end
  end

  context '#payment pattern' do
    context 'when there are too few payments to calculate' do
      its(:payment_date_delta) { is_expected.to eq(nil) }
      its(:payment_amount_delta) { is_expected.to eq(nil) }
    end

    context 'when there are enough payments to compare' do
      let(:transactions) do
        [
          example_transaction(timestamp: Time.now - 25.days, value: -25.00),
          example_transaction(timestamp: Time.now - 15.days, value: -75.00),
          example_transaction(timestamp: Time.now, value: -75.00)
        ]
      end

      subject { described_class.new(tenancy_attributes, transactions) }

      its(:payment_date_delta) { is_expected.to eq(5) }
      its(:payment_amount_delta) { is_expected.to eq(50.00) }
    end
  end

  context '#days_in_arrears' do
    context 'payment has never been made on the account' do
      let(:tenancy_attributes) { example_tenancy(current_balance: '200.00') }
      let(:transactions) { [{ type: 'RNT', timestamp: Time.now - 7.days, value: 200.00 }] }

      its(:days_in_arrears) { is_expected.to eq(7) }
    end

    context 'account has never been in arrears' do
      let(:tenancy_attributes) { example_tenancy(current_balance: '-5.00') }
      let(:transactions) do
        [
          { type: 'RNT', timestamp: Time.now - 6.days, value: -5.00 },
          { type: 'RPY', timestamp: Time.now - 7.days, value: -205.00 }
        ]
      end

      its(:days_in_arrears) { is_expected.to eq(0) }
    end

    context 'account was in credit or at zero' do
      let(:tenancy_attributes) { example_tenancy(current_balance: '25.00') }
      let(:transactions) do
        [
          { type: 'RPY', timestamp: Time.now, value: -25.00 },
          { type: 'RPY', timestamp: Time.now - 15.days, value: -75.00 },
          { type: 'RPY', timestamp: Time.now - 20.days, value: -75.00 },
          { type: 'RNT', timestamp: Time.now - 25.days, value: 200.00 },
          { type: 'RPY', timestamp: Time.now - 40.days, value: -200.00 }
        ]
      end

      its(:days_in_arrears) { is_expected.to eq(25) }
    end

    context 'payments date back 35 days - account was not in credit ever' do
      let(:tenancy_attributes) { example_tenancy(current_balance: '25.00') }
      let(:transactions) do
        [
          { type: 'RPY', timestamp: Time.now, value: -25.00 },
          { type: 'RPY', timestamp: Time.now - 15.days, value: -75.00 },
          { type: 'RPY', timestamp: Time.now - 25.days, value: -75.00 },
          { type: 'RNT', timestamp: Time.now - 35.days, value: 200.00 }
        ]
      end

      its(:days_in_arrears) { is_expected.to eq(35) }
    end

    context 'returns only the most recent arrears period' do
      let(:tenancy_attributes) { example_tenancy(current_balance: '125.00') }
      let(:transactions) do
        [
          { type: 'RPY', timestamp: Time.now, value: -25.00 },
          { type: 'RPY', timestamp: Time.now - 10.days, value: -75.00 },
          { type: 'RPY', timestamp: Time.now - 20.days, value: -75.00 },
          { type: 'RNT', timestamp: Time.now - 30.days, value: 300.00 },
          { type: 'RPY', timestamp: Time.now - 40.days, value: -200.00 },
          { type: 'RNT', timestamp: Time.now - 50.days, value: 200.00 }
        ]
      end

      its(:days_in_arrears) { is_expected.to eq(30) }
    end
  end
end
