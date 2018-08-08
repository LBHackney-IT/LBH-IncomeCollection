describe Hackney::Income::FindOrCreateUser do
  let(:users_gateway) { Hackney::Income::StubSqlUsersGateway.new }
  let(:subject) { described_class.new(users_gateway: users_gateway) }

  context 'when logging in to the app' do
    let(:name) { Faker::Lovecraft.deity }
    let(:uid) { Faker::Number.number(10) }
    let(:email) { Faker::Lovecraft.sentence }
    let(:ad_groups) { "#{Faker::Number.number(6)}.#{Faker::Number.number(6)}" }

    it 'should return a hash for the user' do
      expect(call_subject(uid: uid, name: name, email: email, ad_groups: ad_groups)).to include(
        id: 1,
        name: name,
        email: email,
        ad_groups: ad_groups
      )
    end

    let(:name) { Faker::Lovecraft.deity }
    let(:uid) { Faker::Number.number(10) }

    it 'should create a new user id for each user' do
      call_subject(uid: 'test-uid', name: 'test-name', email: 'test-email', ad_groups: ad_groups)
      expect(call_subject(uid: uid, name: name, email: email, ad_groups: ad_groups)).to include(
        id: 2,
        name: name,
        email: email,
        ad_groups: ad_groups
      )
    end
  end

  def call_subject(uid:, name:, email:, ad_groups:)
    subject.execute(
      provider_uid: uid,
      provider: 'omniauth-active-directory',
      name: name,
      email: email,
      first_name: 'Robert',
      last_name: 'Smith',
      ad_groups: ad_groups
    )
  end
end
