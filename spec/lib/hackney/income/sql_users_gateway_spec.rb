describe Hackney::Income::SqlUsersGateway do
  let(:gateway) { described_class.new }

  context 'when finding or creating a User' do
    subject do
      gateway.find_or_create_user(
        provider_uid: 'close-to-me',
        provider: 'universal',
        name: 'Robert Smith',
        email: 'exploding-boy@the-cure.com',
        first_name: 'Robert',
        last_name: 'Smith',
        ad_groups: '12345.98765'
      )
    end

    context 'and this user does not already exist' do
      before { subject }

      it 'should create a new User instance for that user' do
        expect(Hackney::Models::User.first).to have_attributes(
          provider_uid: 'close-to-me',
          provider: 'universal',
          name: 'Robert Smith',
          email: 'exploding-boy@the-cure.com',
          first_name: 'Robert',
          last_name: 'Smith',
          ad_groups: '12345.98765'
        )
      end
    end

    context 'and a user already exists' do
      before do
        Hackney::Models::User.create!(
          provider_uid: 'close-to-me',
          provider: 'universal',
          name: 'Robert Smith',
          email: 'old-email@the-cure.com',
          first_name: 'Robert',
          last_name: 'Smith',
          ad_groups: '12345.98765'
        )

        subject
      end

      it 'should not create a duplicate user' do
        expect(Hackney::Models::User.count).to eq(1)
      end

      it 'should update the record found' do
        expect(Hackney::Models::User.first.email).to eq('exploding-boy@the-cure.com')
      end
    end

    context 'in either case' do
      it 'should return a hash representing the user' do
        expect(subject).to include(
          id: 1,
          name: 'Robert Smith'
        )
      end
    end
  end
end
