require 'rails_helper'

describe Hackney::Income::CreateActionDiaryEntryGateway do
  subject { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }

  let(:request_params) do
    {
      tenancy_ref: Faker::Lorem.characters(number: 6),
      action_code: Faker::Lorem.characters(number: 3),
      comment: Faker::Lorem.paragraph,
      username: Faker::Name.name
    }
  end

  let(:json_request_body) do
    {
      action_code: request_params.fetch(:action_code),
      comment: request_params.fetch(:comment),
      username: request_params.fetch(:username)
    }.to_json
  end

  context 'when sending a successful request to the API' do
    before do
      stub_request(:post, "https://example.com/api/v1/tenancies/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/action_diary")
        .to_return(
          status: 200
        )
    end

    it 'should send the required params' do
      subject.create_action_diary_entry(request_params)

      assert_requested(
        :post,
        "https://example.com/api/v1/tenancies/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/action_diary",
        headers: { 'Content-Type': 'application/json', 'X-Api-Key': 'skeleton' },
        body: json_request_body,
        times: 1
      )
    end
  end

  context 'when receiving a 500 error from the API' do
    before do
      stub_request(:post, "https://example.com/api/v1/tenancies/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/action_diary")
        .to_return(
          status: 500
        )
    end

    it 'should send the required params' do
      expect do
        subject.create_action_diary_entry(request_params)
      end.to raise_error(
        Exceptions::IncomeApiError,
        "[Income API error: Received 500 response] when trying to create_action_diary_entry using 'https://example.com/api/v1/tenancies/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/action_diary'"
      )
      assert_requested(
        :post,
        "https://example.com/api/v1/tenancies/#{ERB::Util.url_encode(request_params.fetch(:tenancy_ref))}/action_diary",
        headers: { 'Content-Type': 'application/json', 'X-Api-Key': 'skeleton' },
        body: json_request_body,
        times: 1
      )
    end
  end
end
