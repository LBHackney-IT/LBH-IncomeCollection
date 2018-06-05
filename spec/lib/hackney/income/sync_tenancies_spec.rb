require 'rails_helper'

describe Hackney::Income::SyncTenancies do
  let(:stub_tenancy_source_gateway) { Hackney::Income::StubTenancyGatewayBuilder.build_stub(with_tenancies: stub_tenancies).new }
  let(:stub_tenancy_persistence_gateway) { double('tenancy persistence gateway', persist: nil) }
  let(:sync_tenancies) do
    described_class.new(
      tenancy_source_gateway: stub_tenancy_source_gateway,
      tenancy_persistence_gateway: stub_tenancy_persistence_gateway
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
    let(:stub_tenancies) do
      [{
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        title: Faker::Name.title,
        address_1: Faker::Address.street_address,
        tenancy_ref: Faker::IDNumber.valid
      }]
    end

    it 'should return their tenancy refs' do
      expect(subject).to eq([
        stub_tenancies.first.fetch(:tenancy_ref)
      ])
    end

    it 'should attempt to save them' do
      expect(stub_tenancy_persistence_gateway).to receive(:persist).with(tenancies: [{
        address_1: stub_tenancies.first.fetch(:address_1),
        current_balance: '1200.99',
        post_code: 'E1 123',
        tenancy_ref: stub_tenancies.first.fetch(:tenancy_ref),
        primary_contact: {
          first_name: stub_tenancies.first.fetch(:first_name),
          last_name: stub_tenancies.first.fetch(:last_name),
          title: stub_tenancies.first.fetch(:title)
        }
      }])

      subject
    end
  end
end
