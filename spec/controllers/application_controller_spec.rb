require 'rails_helper'

describe ApplicationController, type: :controller do
  let(:valid_jwt_token) { JWT.encode(jwt_payload, ENV['HACKNEY_JWT_SECRET'], 'HS256') }
  let(:invalid_jwt_token) { JWT.encode(jwt_payload, 'bogus', 'HS256') }

  let(:jwt_payload) do
    {
      'sub' => '100518888746922116647',
      'email' => 'hackney.user@test.hackney.gov.uk',
      'iss' => 'Hackney',
      'name' => 'Hackney User',
      'groups' => ['group 1', 'group 2'],
      'iat' => 1_570_462_732
    }
  end

  before do
    request.cookies['hackneyToken'] = jwt_token
  end

  describe '#read_hackney_token' do
    context 'when the cookie is set' do
      let(:jwt_token) { valid_jwt_token }

      it 'sets the current_user from the payload' do
        controller.send(:read_hackney_token)

        expect(controller.current_user).to have_attributes(
          id: jwt_payload['sub'],
          name: jwt_payload['name'],
          email: jwt_payload['email'],
          groups: jwt_payload['groups']
        )
      end

      context 'and the cookie is not valid' do
        let(:jwt_token) { invalid_jwt_token }

        it 'sets the current_user to be nil' do
          controller.send(:read_hackney_token)

          expect(controller.current_user).to be_nil
        end
      end
    end

    context 'when the cookie is not set' do
      let(:jwt_token) { nil }

      it 'returns nil' do
        controller.send(:read_hackney_token)

        expect(controller.current_user).to be_nil
      end
    end

    context 'when the JWT Secret is not set' do
      let(:jwt_token) { valid_jwt_token }
      let!(:original_jwt_secret) { ENV['HACKNEY_JWT_SECRET'].dup }

      before do
        ENV['HACKNEY_JWT_SECRET'] = nil
      end

      after do
        ENV['HACKNEY_JWT_SECRET'] = original_jwt_secret
      end

      it 'raises an error' do
        expect { controller.send(:read_hackney_token) }.to raise_error(
          RuntimeError, 'JWT Secret ENV variable is not set'
        )
      end
    end
  end

  describe '#check_authentication' do
    controller do
      def index
        head(:ok)
      end

      protected

      def groups_allowed_to_read
        ['group 1']
      end
    end

    before do
      expect(controller).to receive(:check_authentication).and_call_original

      get :index
    end

    context 'when there is a valid token' do
      let(:jwt_token) { valid_jwt_token }

      it 'returns true when the groups are valid' do
        expect(response).to be_successful
      end
    end

    context 'when there is an invalid token' do
      let(:jwt_token) { invalid_jwt_token }

      it 'redirects to login page' do
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
