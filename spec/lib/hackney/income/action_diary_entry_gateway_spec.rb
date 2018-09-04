require 'rails_helper'

describe Hackney::Income::ActionDiaryEntryGateway do
  subject { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }
  let(:request_content) do
    {
      arrearsAction: {
        actionBalance: Faker::Number.decimal(2),
        actionCategory: Faker::Lorem.characters(3),
        actionCode: Faker::Lorem.characters(3),
        comment: Faker::Lorem.words(10),
        confirmation: true,
        deferredTo: Date.today,
        isCommentOnly: true,
        newSetRequired: true,
        tenancyAgreementRef: Faker::Lorem.characters(6)
      },
      companyCode: 'FIXME',
      directUser: {
        userName: 'FIXME',
        userPassword: 'FIXME'
      },
      masterPassword: 'FIXME',
      sessionToken: 'FIXME',
      sourceSystem: 'FIXME',
      userId: 0
    }
  end

  before do
    stub_request(:post, "https://example.com/api/tenancies/arrears-action-diary")
  end

  context 'sending a request to the API' do
    it 'should send the required JSON body' do
      subject.create_action_diary_entry(
        tenancy_ref: request_content.dig(:arrearsAction).fetch(:tenancyAgreementRef),
        balance: request_content.dig(:arrearsAction).fetch(:actionBalance),
        code: request_content.dig(:arrearsAction).fetch(:actionCode),
        type: request_content.dig(:arrearsAction).fetch(:actionCategory),
        date: request_content.dig(:arrearsAction).fetch(:deferredTo),
        comment: request_content.dig(:arrearsAction).fetch(:comment),
        universal_housing_username: request_content.dig(:directUser).fetch(:userName)
      )

      assert_requested(:post, 'https://example.com/api/tenancies/arrears-action-diary',
        :headers => { 'Content-Type' => 'application/json', 'x-api-key' => 'skeleton' }, :body => request_content.to_json, :times => 1)
    end
  end
end
