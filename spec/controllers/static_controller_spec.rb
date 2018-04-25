require 'rails_helper'

describe StaticController do
  it 'should display a static landing page' do
    get :homepage
    expect(response.body).to include('hello world')
  end
end
