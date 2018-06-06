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

  def example_tenancy(attributes = {})
    agreements = attributes
      .fetch(:agreements, [])
      .map(&method(:example_agreement))

    arrears_actions = attributes
      .fetch(:arrears_actions, [])
      .map(&method(:example_arrears_action))

    {
      ref: attributes.fetch(:tenancy_ref, '000001/FAKE'),
      current_balance: attributes.fetch(:current_balance, '1200.99'),
      type: 'SEC',
      start_date: '2018-01-01',
      primary_contact: {
        first_name: 'Waffles',
        last_name: 'The Dog',
        title: 'Ms',
        contact_number: '0208 123 1234',
        email_address: 'test@example.com'
      },
      address: {
        address_1: '136 Southwark Street',
        address_2: 'Hackney',
        address_3: 'London',
        address_4: 'UK',
        post_code: 'E1 123'
      },
      agreements: agreements,
      arrears_actions: arrears_actions
    }
  end

  def example_transaction(attributes = {})
    attributes.reverse_merge(
      id: '123-456-789',
      timestamp: Time.now,
      tenancy_ref: '3456789',
      description: 'Rent Payment',
      value: -50.00,
      type: 'RPY'
    )
  end

  def example_agreement(attributes = {})
    attributes.reverse_merge(
      status: 'active',
      type: 'court_ordered',
      value: '10.99',
      frequency: 'weekly',
      created_date: '2017-11-01'
    )
  end

  def example_arrears_action(attributes = {})
    attributes.reverse_merge(
      type: 'general_note',
      automated: false,
      user: { name: 'Brainiac' },
      date: Time.now.strftime('%Y-%m-%d'),
      description: 'this tenant is in arrears!'
    )
  end
end
