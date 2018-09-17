class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[create]
  skip_before_action :check_authentication, only: %i[new]

  def new; end

  def create
    pp auth_hash
    if auth_hash.extra.raw_info.nil? || !user_has_ic_staff_permissions?
      flash[:notice] = 'You do not have the required access permission'
      return redirect_to login_path
    end

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
  end

  def destroy
    session[:current_user] = nil
    flash[:notice] = 'You have been signed out'
    redirect_to login_path
  end

  private

  def user_has_ic_staff_permissions?
    auth_hash.extra.raw_info.id_token.split('.').include?(ENV['IC_STAFF_GROUP'])
  end

  def auth_hash
    request.env['omniauth.auth']
  end
end
