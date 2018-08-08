class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[create]
  skip_before_action :check_authentication, only: %i[new]

  def new; end

  def create
    puts auth_hash
    flash[:notice] = 'You do not have the required access permission' and return redirect_to login_path if auth_hash.extra.nil? || !check_active_groups

    user = find_or_create_user.execute(
      provider_uid: auth_hash.uid,
      provider: auth_hash.provider,
      name: auth_hash.info.name,
      email: auth_hash.info.email,
      first_name: auth_hash.info.first_name,
      last_name: auth_hash.info.last_name,
      ad_groups: auth_hash.extra.raw_info.id_token
    )

    session[:current_user] = {
      'id' => user.fetch(:id),
      'name' => user.fetch(:name),
      'email' => user.fetch(:email),
      'groups_token' => user.fetch(:ad_groups)
     }

    redirect_to root_path and return
  end

  def destroy
    session[:current_user] = nil
    flash[:notice] = 'You have been signed out'
    redirect_to login_path
  end

  private

  def check_active_groups
    auth_hash.extra.raw_info.id_token.split('.').include?(ENV['IC_STAFF_GROUP'])
  end

  def auth_hash
    request.env['omniauth.auth']
  end

  def find_or_create_user
    Hackney::Income::FindOrCreateUser.new(users_gateway: users_gateway)
  end

  def users_gateway
    Hackney::Income::SqlUsersGateway.new
  end
end
