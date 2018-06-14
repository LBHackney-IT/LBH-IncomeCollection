require 'rails_helper'

describe Hackney::Income::SyncTenancies do
  let(:stub_users) { [] }
  let(:stub_tenancy_source_gateway) { Hackney::Income::StubTenancyGatewayBuilder.build_stub(with_tenancies: stub_tenancies).new }
  let(:stub_tenancy_persistence_gateway) { double('tenancy persistence gateway', persist: nil, assign_user: nil) }
  let(:stub_transactions_gateway) { Hackney::Income::StubTransactionsGateway.new }
  let(:stub_users_gateway) { double('users gateway', all_users: stub_users) }
  let(:sync_tenancies) do
    described_class.new(
      tenancy_source_gateway: stub_tenancy_source_gateway,
      tenancy_persistence_gateway: stub_tenancy_persistence_gateway,
      transactions_gateway: stub_transactions_gateway,
      users_gateway: stub_users_gateway
    )
  end

  subject { sync_tenancies.execute }

  context 'when there are no tenancies available to sync' do
    let(:stub_tenancies) { [] }

    it 'should return no results' do
      expect(subject).to eq([])
    end
  end

  context 'when there are tenancies available to sync' do
    let(:tenancy_ref) { Faker::IDNumber.valid }
    let(:stub_tenancies) { [create_stub_tenancy(tenancy_ref)] }

    it 'should return their tenancy refs' do
      expect(subject).to eq([tenancy_ref])
    end

    it 'should retrieve their full tenancy details' do
      expect(stub_tenancy_source_gateway).to receive(:get_tenancy).with(tenancy_ref: tenancy_ref).and_call_original
      subject
    end

    it 'should retrieve their transaction history' do
      expect(stub_transactions_gateway).to receive(:transactions_for).with(tenancy_ref: tenancy_ref).and_call_original
      subject
    end

    it 'should attempt to save their necessary listing details' do
      allow_any_instance_of(Hackney::Income::TenancyPrioritiser).to receive(:priority_band).and_return(:green)
      expect(stub_tenancy_persistence_gateway).to receive(:persist).with(tenancy: {
        address_1: stub_tenancies.first.fetch(:address_1),
        current_balance: stub_tenancies.first.fetch(:current_balance),
        post_code: stub_tenancies.first.fetch(:post_code),
        tenancy_ref: stub_tenancies.first.fetch(:tenancy_ref),
        priority_band: :green,
        primary_contact: {
          first_name: stub_tenancies.first.fetch(:first_name),
          last_name: stub_tenancies.first.fetch(:last_name),
          title: stub_tenancies.first.fetch(:title)
        }
      })

      subject
    end

    it 'should determine their priority band' do
      expect_any_instance_of(Hackney::Income::TenancyPrioritiser).to receive(:priority_band).and_call_original
      subject
    end

    context 'and a priority band is determined' do
      let(:priority_band) { Faker::Space.galaxy }

      it 'should persist the correct band' do
        allow_any_instance_of(Hackney::Income::TenancyPrioritiser).to receive(:priority_band).and_return(priority_band)
        expect(stub_tenancy_persistence_gateway).to receive(:persist).with(tenancy: a_hash_including(priority_band: priority_band))

        subject
      end
    end

    context 'but there are no system users' do
      it 'should not assign any tenancies' do
        expect(stub_tenancy_persistence_gateway).to_not receive(:assign_user)
        subject
      end
    end

    context 'and there is a single system user' do
      let(:user_id) { Faker::Number.number.to_i }
      let(:stub_users) { [{ id: user_id }] }
      let(:tenancy_refs) { 3.times.to_a.map { Faker::IDNumber.valid } }
      let(:stub_tenancies) { tenancy_refs.map(&method(:create_stub_tenancy)) }

      it 'should assign that user all of the tenancies' do
        tenancy_refs.each do |ref|
          expect(stub_tenancy_persistence_gateway).to receive(:assign_user).with(tenancy_ref: ref, user_id: user_id)
        end

        subject
      end
    end

    context 'and there is more than one system user' do
      let(:first_user_id) { Faker::Number.number.to_i }
      let(:second_user_id) { Faker::Number.number.to_i }
      let(:stub_users) { [{ id: first_user_id }, { id: second_user_id }] }
      let(:tenancy_refs) { 6.times.to_a.map { Faker::IDNumber.valid } }
      let(:stub_tenancies) { tenancy_refs.map(&method(:create_stub_tenancy)) }

      it 'should assign the cases evenly based on priority band to all users' do
        stub_tenancy_ref_priority_bands(
          tenancy_refs[0] => :noble_purple,
          tenancy_refs[1] => :noble_purple,
          tenancy_refs[2] => :noble_purple,
          tenancy_refs[3] => :noble_purple,
          tenancy_refs[4] => :parrot_green,
          tenancy_refs[5] => :parrot_green
        )

        expect_tenancies_assigned_to(
          tenancy_refs[0] => first_user_id,
          tenancy_refs[1] => second_user_id,
          tenancy_refs[2] => first_user_id,
          tenancy_refs[3] => second_user_id,
          tenancy_refs[4] => first_user_id,
          tenancy_refs[5] => second_user_id
        )

        subject
      end
    end
  end

  def create_stub_tenancy(tenancy_ref)
    {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      title: Faker::Name.title,
      address_1: Faker::Address.street_address,
      tenancy_ref: tenancy_ref,
      post_code: Faker::Address.postcode,
      current_balance: Faker::Number.decimal(2)
    }
  end

  def stub_tenancy_ref_priority_bands(tenancy_refs_to_priority_bands)
    spy_prioritiser = class_double('Hackney::Income::TenancyPrioritiser').as_stubbed_const

    tenancy_refs_to_priority_bands.each do |tenancy_ref, priority_band|
      spy_prioritiser_instance = double(priority_band: priority_band)

      allow(spy_prioritiser)
        .to receive(:new)
        .with(tenancy: a_hash_including(ref: tenancy_ref), transactions: anything)
        .and_return(spy_prioritiser_instance)
        .once
    end
  end

  def expect_tenancies_assigned_to(tenancy_refs_to_user_ids)
    tenancy_refs_to_user_ids.each do |expected_tenancy_ref, expected_user_id|
      expect(stub_tenancy_persistence_gateway)
        .to receive(:assign_user)
        .with(tenancy_ref: expected_tenancy_ref, user_id: expected_user_id)
        .ordered
    end
  end
end
