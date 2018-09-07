require 'rails_helper'

describe Hackney::Income::CreateActionDiaryEntry do
  let(:action_diary_gateway) { Hackney::Income::StubActionDiaryEntryGateway.new(api_host: nil, api_key: nil) }
  let(:params) do
    {
      tenancy_ref: Faker::Lorem.characters(6),
      balance: Faker::Number.decimal(2).to_s,
      code: Faker::Lorem.characters(2),
      type: Faker::Seinfeld.character,
      date: Date.today.strftime('%YYYY-%MM-%DD'),
      comment: Faker::Seinfeld.quote,
      universal_housing_username: Faker::Seinfeld.character
    }
  end

  subject { described_class.new(action_diary_gateway: action_diary_gateway) }

  it 'should pass the required data through to the gateway' do
    expect(action_diary_gateway).to receive(:create_action_diary_entry).with(
      tenancy_ref: params.fetch(:tenancy_ref),
      balance: params.fetch(:balance),
      code: params.fetch(:code),
      type: params.fetch(:type),
      date: params.fetch(:date),
      comment: params.fetch(:comment),
      universal_housing_username: params.fetch(:universal_housing_username)
    )

    subject.execute(
      tenancy_ref: params.fetch(:tenancy_ref),
      balance: params.fetch(:balance),
      code: params.fetch(:code),
      type: params.fetch(:type),
      date: params.fetch(:date),
      comment: params.fetch(:comment),
      universal_housing_username: params.fetch(:universal_housing_username)
    )
  end
end
