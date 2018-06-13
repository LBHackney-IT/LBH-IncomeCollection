require 'rails_helper'

describe Hackney::Income::SyncTenancies do
  let(:stub_tenancy_source_gateway) { Hackney::Income::StubTenancyGatewayBuilder.build_stub(with_tenancies: stub_tenancies).new }
  let(:stub_tenancy_persistence_gateway) { double('tenancy persistence gateway', persist: nil) }
  let(:stub_transactions_gateway) { Hackney::Income::StubTransactionsGateway.new }
  let(:sync_tenancies) do
    described_class.new(
      tenancy_source_gateway: stub_tenancy_source_gateway,
      tenancy_persistence_gateway: stub_tenancy_persistence_gateway,
      transactions_gateway: stub_transactions_gateway
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
    let(:stub_tenancies) do
      [{
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        title: Faker::Name.title,
        address_1: Faker::Address.street_address,
        tenancy_ref: tenancy_ref,
        post_code: Faker::Address.postcode,
        current_balance: Faker::Number.decimal(2)
      }]
    end

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
      expect(stub_tenancy_persistence_gateway).to receive(:persist).with(tenancies: [{
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
      }])

      subject
    end

    it 'should determine their priority band' do
      expect_any_instance_of(Hackney::Income::TenancyPrioritiser).to receive(:priority_band).and_call_original
      subject
    end

    context 'when a priority band is determined' do
      let(:priority_band) { Faker::Space.galaxy }

      it 'should persist the correct band' do
        allow_any_instance_of(Hackney::Income::TenancyPrioritiser).to receive(:priority_band).and_return(priority_band)
        expect(stub_tenancy_persistence_gateway).to receive(:persist).with(tenancies: include(
          a_hash_including(
            priority_band: priority_band
          )
        ))

        subject
      end
    end
  end
end
