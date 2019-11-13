require 'rails_helper'

describe Hackney::Income::CreateActionDiaryEntry do
  let(:create_action_diary_gateway) { instance_double(Hackney::Income::CreateActionDiaryEntryGateway) }
  let(:create_action_diary_entry_params) do
    {
      tenancy_ref: Faker::Lorem.characters(6),
      action_code: Faker::Lorem.characters(3),
      comment: Faker::Lorem.paragraph,
      username: Faker::Name.name
    }
  end

  subject { described_class.new(create_action_diary_gateway: create_action_diary_gateway) }

  it 'should pass the required data through to the gateway' do
    expect(create_action_diary_gateway).to receive(:create_action_diary_entry).with(create_action_diary_entry_params)
    subject.execute(create_action_diary_entry_params)
  end
end
