require 'rails_helper'

xdescribe Hackney::Income::SyncTenancies do
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
      expect(stub_tenancy_persistence_gateway).to receive(:persist) do |args|
        expect(args[:tenancies][0]).to be_instance_of(Hackney::Income::Domain::TenancyListItem)
        expect(args[:tenancies][0].ref).to eq(stub_tenancies[0][:tenancy_ref])
      end

      subject
    end
  end
end
