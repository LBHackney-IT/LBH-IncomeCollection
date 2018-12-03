require 'rails_helper'

describe SessionsController do
  context 'before logging in' do
    it 'should have no session user' do
      expect(session[:current_user]).to be_nil
    end
  end

  context 'when logging in and creating a session' do
    let(:provider_uid) { Faker::Number.number(12).to_s }
    let(:info_hash) do
      {
        name: Faker::StarTrek.character,
        email: "#{Faker::StarTrek.character}@enterprise.fed.gov",
        first_name: Faker::StarTrek.specie,
        last_name: Faker::StarTrek.villain
      }
    end
    let(:user_id) do
      Hackney::Income::StubIncomeApiUsersGateway.generate_id(provider_uid: provider_uid, name: info_hash.fetch(:name))
    end
    let(:extra_hash) do
      {
        raw_info:
        {
          id_token: "#{Faker::Number.number(6)}.123456ABC"
        }
      }
    end

    before do
      stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:azureactivedirectory]
    end

    let(:provider_attributes) do
      {
       uid: provider_uid,
       info: info_hash
      }
    end

    around { |example| with_mock_authentication(attributes: provider_attributes) { example.run } }

    it 'should pass the correct data from the provider to the use case' do
      expect_any_instance_of(Hackney::Income::FindOrCreateUser).to receive(:execute).with(
        provider_uid: provider_uid,
        provider: 'azureactivedirectory',
        name: info_hash.fetch(:name),
        email: info_hash.fetch(:email),
        first_name: info_hash.fetch(:first_name),
        last_name: info_hash.fetch(:last_name),
        provider_permissions: true
      ).and_return(
        id: user_id,
        name: info_hash.fetch(:name),
        email: info_hash.fetch(:email),
        first_name: info_hash.fetch(:first_name),
        last_name: info_hash.fetch(:last_name),
        provider_permissions: extra_hash.fetch(:raw_info).fetch(:id_token)
      )

      get :create, params: { provider: 'azure_activedirectory' }
    end

    it 'should create a session for the user' do
      get :create, params: { provider: 'azure_activedirectory' }

      expect(session[:current_user]).to include(
        'id' => user_id,
        'name' => info_hash.fetch(:name),
        'email' => info_hash.fetch(:email),
        'groups_token' => true
      )
    end
  end

  context 'when the user fails to authenticate' do
    before do
      stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:azureactivedirectory] = :invalid_credentials
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:azureactivedirectory]
    end

    after do
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth.delete(:azureactivedirectory)
      request.env['omiauth.auth'] = nil
    end

    it 'should not allow login' do
      get :create, params: { provider: 'azureactivedirectory' }
      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to be_present
    end
  end
end
