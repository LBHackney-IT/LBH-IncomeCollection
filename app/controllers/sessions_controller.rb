class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[create]
  skip_before_action :check_authentication, only: %i[new]

  def new; end

  def failure
    flash[:notice] = 'Failed to authenticate your Azure Active Directory account'
    redirect_to login_path
  end

  def create
    return failure if auth_hash == :invalid_credentials || auth_hash.nil?

    user = use_cases.find_or_create_user.execute(
      provider_uid: auth_hash.uid,
      provider: auth_hash.provider,
      name: auth_hash.info.name,
      email: auth_hash.info.email,
      first_name: auth_hash.info.first_name,
      last_name: auth_hash.info.last_name,
      provider_permissions: true
    )

    session[:current_user] = {
      'id' => user.fetch(:id),
      'name' => user.fetch(:name),
      'email' => user.fetch(:email),
      'groups_token' => user.fetch(:provider_permissions)
    }

    redirect_to root_path
  rescue OmniAuth::Strategies::AzureActiveDirectory::OAuthError
    failure
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
