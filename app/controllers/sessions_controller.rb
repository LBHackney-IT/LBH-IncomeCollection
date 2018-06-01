class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[create]
  skip_before_action :check_authentication, only: %i[new]

  def new; end

  def create
    session[:current_user] = { name: auth_hash.info.name }
    redirect_to root_path
  end

  def destroy
    session[:current_user] = nil
    flash[:notice] = 'You have been signed out'
    redirect_to login_path
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end
end
