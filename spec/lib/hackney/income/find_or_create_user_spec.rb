describe Hackney::Income::FindOrCreateUser do
  let(:users_gateway) { Hackney::Income::StubUsersGateway.new() }
  let(:subject) { described_class.new(users_gateway: users_gateway) }

  context 'when logging in to the app' do
    let(:name) { Faker::Lovecraft.deity }
    let(:uid) { Faker::Number.number(10) }

    it 'should return a hash for the user' do
      expect(call_subject(uid: uid, name: name)).to include(
        id: 1,
        name: name
      )
    end

    let(:name) { Faker::Lovecraft.deity }
    let(:uid) { Faker::Number.number(10) }

    it 'should create a new user id for each user' do
      call_subject(uid: 'test-uid', name: 'test-name')
      expect(call_subject(uid: uid, name: name)).to include(
        id: 2,
        name: name
      )
    end
  end


  def call_subject(uid:, name:)
    subject.execute(
      provider_uid: uid,
      provider: 'omniauth-active-directory',
      name: name,
      email: 'exploding-boy@the-cure.com',
      first_name: 'Robert',
      last_name: 'Smith'
    )
  end
end
