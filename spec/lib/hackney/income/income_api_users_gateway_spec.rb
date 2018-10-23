require 'rails_helper'

describe Hackney::Income::IncomeApiUsersGateway do
  subject { described_class.new(api_host: 'https://example.com/api', api_key: 'skeleton') }

  let(:params) do
    {
      provider_uid: Faker::Lorem.characters(10),
      provider: Faker::Lorem.word,
      name: Faker::Name.name,
      email: Faker::Internet.email,
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      provider_permissions: Faker::Lorem.characters(4)
    }
  end

  let(:response) do
    {
      id: Faker::Number.number(4),
      name: params.fetch(:name),
      email: params.fetch(:email),
      first_name: params.fetch(:first_name),
      last_name: params.fetch(:last_name),
      provider_permissions: params.fetch(:provider_permissions)
    }
  end

  let(:param_string) { URI.encode_www_form(params) }

  context 'when a user has successfully logged in' do
    before do
      stub_request(:post, "https://example.com/api/users/find-or-create?#{param_string}")
      .to_return(
        body: response.to_json
      )
    end

    it 'should receive details of the user and make an API request' do
      expect(
        subject.find_or_create_user(
          provider_uid: params.fetch(:provider_uid),
          provider: params.fetch(:provider),
          name: params.fetch(:name),
          email: params.fetch(:email),
          first_name: params.fetch(:first_name),
          last_name: params.fetch(:last_name),
          provider_permissions: params.fetch(:provider_permissions)
        )
      ).to eq(response)
    end
  end

  context 'when the backend throws an error' do
    before do
      stub_request(:post, "https://example.com/api/users/find-or-create?#{param_string}")
      .to_return(status: [500, 'Internal Server Error'])
    end

    let(:provider_uid) { params.fetch(:provider_uid) }

    it 'should not login' do
      expect do
        subject.find_or_create_user(
          provider_uid: params.fetch(:provider_uid),
          provider: params.fetch(:provider),
          name: params.fetch(:name),
          email: params.fetch(:email),
          first_name: params.fetch(:first_name),
          last_name: params.fetch(:last_name),
          provider_permissions: params.fetch(:provider_permissions)
        )
      end.to raise_error(Exceptions::IncomeApiError, "[Income API error: Received 500 responce] when trying to find_or_create_user with UID '#{params.fetch(:provider_uid)}'")
    end
  end
end
