describe Hackney::Income::UpdateTenancy do
  let(:tenancy_gateway) { Hackney::Income::StubTenancyGatewayBuilder.build_stub.new }

  let(:params) do
    {
        tenancy_ref: Faker::Lorem.characters(6),
        is_paused_until: Faker::Date.forward(23)
    }
  end

  subject { described_class.new(tenancy_gateway: tenancy_gateway) }

  it 'should pass the required data through to the gateway' do
    expect(tenancy_gateway).to receive(:update_tenancy).with(
      tenancy_ref: params.fetch(:tenancy_ref),
      is_paused_until: params.fetch(:is_paused_until)
    )

    subject.execute(
      tenancy_ref: params.fetch(:tenancy_ref),
      is_paused_until: params.fetch(:is_paused_until)
    )
  end
end
