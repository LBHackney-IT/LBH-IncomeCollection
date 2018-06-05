describe Hackney::Income::FindOrCreateUser do
  let(:users_gateway) { Hackney::Income::StubSqlUsersGateway.new }
  let(:subject) { described_class.new(users_gateway: users_gateway) }

  context 'when logging in to the app' do
    let(:name) { Faker::Lovecraft.deity }
    let(:uid) { Faker::Number.number(10) }
    let(:email) { Faker::Lovecraft.sentence }

    it 'should return a hash for the user' do
      expect(call_subject(uid: uid, name: name, email: email)).to include(
        id: 1,
        name: name,
        email: email
      )
    end

    let(:name) { Faker::Lovecraft.deity }
    let(:uid) { Faker::Number.number(10) }

    it 'should create a new user id for each user' do
      call_subject(uid: 'test-uid', name: 'test-name', email: 'test-email')
      expect(call_subject(uid: uid, name: name, email: email)).to include(
        id: 2,
        name: name,
        email: email
      )
    end
  end

  def call_subject(uid:, name:, email:)
    subject.execute(
      provider_uid: uid,
      provider: 'omniauth-active-directory',
      name: name,
      email: email,
      first_name: 'Robert',
      last_name: 'Smith'
    )
  end
end
