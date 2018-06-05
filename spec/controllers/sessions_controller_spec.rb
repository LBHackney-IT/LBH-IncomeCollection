require 'rails_helper'

describe SessionsController do
  context 'before logging in' do
    it 'should have no session user' do
      expect(session[:current_user]).to be_nil
    end
  end

  context 'when logging in and creating a session' do
    before do
      stub_const('Hackney::Income::UsersGateway', Hackney::Income::StubUsersGateway)

      @provider_uid = Faker::Number.number(12).to_s
      @info_hash = {
        name: Faker::StarTrek.character,
        email: "#{Faker::StarTrek.character}@enterprise.fed.gov",
        first_name: Faker::StarTrek.specie,
        last_name: Faker::StarTrek.villain
      }

      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:azure_activedirectory] = OmniAuth::AuthHash.new({
        provider: 'azure_activedirectory',
        uid: @provider_uid,
        info: @info_hash
      })

      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:azure_activedirectory]
    end

    after do
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth.delete(:azure_activedirectory)
    end

    it 'should pass the correct data from the provider to the use case' do
      expect_any_instance_of(Hackney::Income::FindOrCreateUser).to receive(:execute).with(
        provider_uid: @provider_uid,
        provider: 'azure_activedirectory',
        name: @info_hash.fetch(:name),
        email: @info_hash.fetch(:email),
        first_name: @info_hash.fetch(:first_name),
        last_name: @info_hash.fetch(:last_name)
      ).and_return({
        id: 1,
        name: @info_hash.fetch(:name),
        email: @info_hash.fetch(:email),
        first_name: @info_hash.fetch(:first_name),
        last_name: @info_hash.fetch(:last_name)
      })

      get :create, params: { provider: 'azure_activedirectory' }
    end

    it 'should create a session for the user' do
      get :create, params: { provider: 'azure_activedirectory' }

      expect(assigns(:user)).to be_present
      expect(assigns(:user)).to include(
        provider_uid: @provider_uid,
        provider: 'azure_activedirectory',
        name: @info_hash.fetch(:name),
        email: @info_hash.fetch(:email),
        first_name: @info_hash.fetch(:first_name),
        last_name: @info_hash.fetch(:last_name)
      )

      expect(session[:current_user]).to include(
        id: 1,
        name: @info_hash.fetch(:name),
        email: @info_hash.fetch(:email)
      )
    end
  end
end
