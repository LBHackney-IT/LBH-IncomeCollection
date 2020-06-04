require 'rails_helper'

describe Hackney::Income::FindOrCreateUser do
  let(:users_gateway) { Hackney::Income::StubIncomeApiUsersGateway.new(api_host: nil, api_key: nil) }
  let(:subject) { described_class.new(users_gateway: users_gateway) }

  context 'when logging in to the app' do
    let(:name) { Faker::Books::Lovecraft.deity }
    let(:uid) { Faker::Number.number(digits: 10) }
    let(:email) { Faker::Books::Lovecraft.sentence }
    let(:provider_permissions) { "#{Faker::Number.number(digits: 6)}.#{Faker::Number.number(digits: 6)}" }

    it 'should return a hash for the user' do
      expect(call_subject(uid: uid, name: name, email: email, provider_permissions: provider_permissions)).to include(
        id: Hackney::Income::StubIncomeApiUsersGateway.generate_id(provider_uid: uid, name: name),
        name: name,
        email: email,
        provider_permissions: provider_permissions
      )
    end

    let(:name) { Faker::Books::Lovecraft.deity }
    let(:uid) { Faker::Number.number(digits: 10) }

    it 'should create a new user id for each user' do
      call_subject(uid: 'test-uid', name: 'test-name', email: 'test-email', provider_permissions: provider_permissions)
      expect(call_subject(uid: uid, name: name, email: email, provider_permissions: provider_permissions)).to include(
        id: Hackney::Income::StubIncomeApiUsersGateway.generate_id(provider_uid: uid, name: name),
        name: name,
        email: email,
        provider_permissions: provider_permissions
      )
    end
  end

  def call_subject(uid:, name:, email:, provider_permissions:)
    subject.execute(
      provider_uid: uid,
      provider: 'omniauth-active-directory',
      name: name,
      email: email,
      first_name: 'Robert',
      last_name: 'Smith',
      provider_permissions: provider_permissions
    )
  end
end
