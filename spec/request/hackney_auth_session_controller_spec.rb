require 'rails_helper'

describe HackneyAuthSessionController, type: :request do
  it 'renders the correct Auth URL' do
    get login_path

    expect(response).to be_successful
    expect(response).to render_template(:show)

    url = 'https://auth.hackney.gov.u/auth?redirect_uri=https://testing.managearrears.hackney.gov.uk/'
    expect(response.body).to include(url)
  end
end
