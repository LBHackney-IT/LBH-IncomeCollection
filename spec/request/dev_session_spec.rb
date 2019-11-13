require 'rails_helper'

describe 'DevSessionController', type: :request do
  context 'in a non development environment' do
    it 'the route does not exist' do
      expect { get '/login/dev' }.to raise_error(
        ActionController::RoutingError, 'No route matches [GET] "/login/dev"'
      )
    end
  end
end
