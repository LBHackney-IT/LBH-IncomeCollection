require 'rails_helper'

describe Hackney::Income::ActionDiaryEntryGateway do
  subject { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }

  let(:request_content) do
    {
      arrearsAction: {
        actionBalance: Faker::Number.decimal(2),
        actionCategory: '',
        actionCode: Faker::Lorem.characters(3),
        comment: Faker::Lorem.words(10),
        confirmation: true,
        tenancyAgreementRef: Faker::Lorem.characters(6)
      },
      companyCode: '',
      directUser: {
        userName: '',
        userPassword: ''
      },
      masterPassword: '',
      sessionToken: '',
      sourceSystem: '',
      userId: 0
    }
  end

  let(:actions_response) do
    {
      arrears_action_diary_events:
      [
        {
          balance: Faker::Number.decimal(2),
          code: Faker::Lorem.characters(3),
          type: Faker::Lorem.characters(3),
          date: Faker::Date.forward(100),
          comment: Faker::Lorem.words(10),
          universal_housing_username: Faker::Lorem.words(2)
        },
        {
          balance: Faker::Number.decimal(2),
          code: Faker::Lorem.characters(3),
          type: Faker::Lorem.characters(3),
          date: Faker::Date.forward(100),
          comment: Faker::Lorem.words(10),
          universal_housing_username: Faker::Lorem.words(2)
        }
      ]
    }
  end

  before do
    stub_request(:post, 'https://example.com/api/tenancies/arrears-action-diary')
    stub_request(:get, 'https://example.com/api/tenancies/FAKE%2F01/actions')
      .to_return(
        body: actions_response.to_json
      )
  end

  context 'sending a request to the API' do
    it 'should send the required JSON body' do
      subject.create_action_diary_entry(
        tenancy_ref: request_content.dig(:arrearsAction).fetch(:tenancyAgreementRef),
        balance: request_content.dig(:arrearsAction).fetch(:actionBalance),
        code: request_content.dig(:arrearsAction).fetch(:actionCode),
        type: request_content.dig(:arrearsAction).fetch(:actionCategory),
        date: Date.today,
        comment: request_content.dig(:arrearsAction).fetch(:comment),
        universal_housing_username: request_content.dig(:directUser).fetch(:userName)
      )

      assert_requested(
        :post,
        'https://example.com/api/tenancies/arrears-action-diary',
        headers: { 'Content-Type': 'application/json', 'X-Api-Key': 'skeleton' },
        body: request_content.to_json,
        times: 1
      )
    end
  end

  context 'getting action diary entries for a tenancy' do
    it 'should return action diary events' do
      actions = subject.get_actions_for(tenancy_ref: 'FAKE/01')

      assert_action_diary_entry(actions[0], actions_response[:arrears_action_diary_events][0])
      assert_action_diary_entry(actions[1], actions_response[:arrears_action_diary_events][1])
    end
  end

  def assert_action_diary_entry(entry, expected)
    expect(entry).to be_instance_of(Hackney::Income::Domain::ActionDiaryEntry)
    expect(entry.balance).to eq(expected.fetch(:balance).to_s)
    expect(entry.code).to eq(expected.fetch(:code))
    expect(entry.type).to eq(expected.fetch(:type))
    expect(entry.date).to eq(expected.fetch(:date).strftime('%Y-%m-%d'))
    expect(entry.comment).to eq(expected.fetch(:comment))
    expect(entry.universal_housing_username).to eq(expected.fetch(:universal_housing_username))
  end
end
