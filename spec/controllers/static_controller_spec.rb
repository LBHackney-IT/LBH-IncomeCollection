require 'rails_helper'

describe StaticController do
  render_views

  it 'should display a static landing page' do
    get :homepage
    expect(response.body).to include('Hello World!')
  end
end
