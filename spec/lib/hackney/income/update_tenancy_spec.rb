describe Hackney::Income::UpdateTenancy do
  let(:tenancy_gateway) { Hackney::Income::StubTenancyGatewayBuilder.build_stub.new }

  let(:params) do
    {
        tenancy_ref: Faker::Lorem.characters(6),
        is_paused_until_date: Faker::Date.forward(23),
        pause_reason: Faker::Lorem.sentence,
        pause_comment: Faker::Lorem.paragraph,
        user_id: Faker::Number.number(2),
        action_code: Faker::Internet.slug
    }
  end

  subject { described_class.new(tenancy_gateway: tenancy_gateway) }

  it 'should pass the required data through to the gateway' do
    expect(tenancy_gateway).to receive(:update_tenancy).with(
      tenancy_ref: params.fetch(:tenancy_ref),
      is_paused_until_date: params.fetch(:is_paused_until_date),
      pause_reason: params.fetch(:pause_reason),
      pause_comment: params.fetch(:pause_comment),
      user_id: params.fetch(:user_id),
      action_code: params.fetch(:action_code)
    )

    subject.execute(
      tenancy_ref: params.fetch(:tenancy_ref),
      is_paused_until_date: params.fetch(:is_paused_until_date),
      pause_reason: params.fetch(:pause_reason),
      pause_comment: params.fetch(:pause_comment),
      user_id: params.fetch(:user_id),
      action_code: params.fetch(:action_code)
    )
  end
end
