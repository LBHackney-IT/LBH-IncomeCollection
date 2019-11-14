require 'rails_helper'

describe HackneyAuthSessionController, type: :request do
  it 'renders the correct Auth URL' do
    get login_path

    expect(response).to be_successful
    expect(response).to render_template(:new)

    url = 'https://auth.hackney.gov.u/auth?redirect_uri=https://testing.managearrears.hackney.gov.uk/'
    expect(response.body).to include(url)
  end

  context 'when the hackneyToken is set' do
    before do
      host! 'test.managearrears.hackney.gov.uk'
      cookies['hackneyToken'] = build_jwt_token
    end

    context 'and the user logs out' do
      before do
        get logout_path
      end

      xit 'destroys the hackneyToken' do
        expect(cookies['hackneyToken']).to eq('')
      end

      it 'redirects to the root path' do
        expect(response).to redirect_to(root_path)
      end

      it 'the response contains a `Set-Cookie` header blanking `hackneyToken`' do
        expect(response.headers['Set-Cookie']).to include('hackneyToken=;')
      end

      it 'the response contains a `Set-Cookie` header with the correct domain' do
        expect(response.headers['Set-Cookie']).to include('domain=.hackney.gov.uk;')
      end
    end
  end
end
