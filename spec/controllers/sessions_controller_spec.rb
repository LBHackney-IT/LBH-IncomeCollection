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

      OmniAuth.config.test_mode = true
      OmniAuth.config.add_mock(
        :azure_activedirectory,
        info: {
          name: 'William T. Riker',
          email: 'w.riker@enterprise.fed.gov',
          first_name: 'William',
          last_name: 'Riker'
        }
      )
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:azure_activedirectory]
    end

    after do
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth.delete(:azure_activedirectory)
    end

    it 'should create a session for the user' do
      get :create, params: { provider: 'azure_activedirectory' }

      expect(assigns(:user)).to be_present
      expect(assigns(:user)).to include(
        provider_uid: '1234',
        provider: 'azure_activedirectory',
        name: 'William T. Riker',
        email: 'w.riker@enterprise.fed.gov',
        first_name: 'William',
        last_name: 'Riker'
      )

      expect(session[:current_user]).to include(
        id: 1,
        name: 'William T. Riker',
        email: 'w.riker@enterprise.fed.gov'
      )
    end
  end
end
