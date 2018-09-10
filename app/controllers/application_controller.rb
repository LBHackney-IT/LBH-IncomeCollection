class ApplicationController < ActionController::Base
  if Rails.env.staging? || Rails.env.production?
    http_basic_authenticate_with name: ENV['BASIC_AUTH_USERNAME'], password: ENV['BASIC_AUTH_PASSWORD']
  end

  helper_method :logged_in?
  helper_method :current_user

  before_action :check_authentication

  def use_cases
    @use_cases ||= Hackney::Income::UseCaseFactory.new
  end

  def current_user
    session[:current_user]
  end

  private

  def check_authentication
    return if logged_in? || auth_request? || logout_request?
    redirect_to login_path
  end

  def logged_in?
    current_user.present?
  end

  def auth_request?
    request.path.starts_with?('/auth/')
  end

  def logout_request?
    request.path == '/logout'
  end
end
