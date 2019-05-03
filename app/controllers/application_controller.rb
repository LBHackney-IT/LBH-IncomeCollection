class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: ENV['BASIC_AUTH_USERNAME'], password: ENV['BASIC_AUTH_PASSWORD'] if Rails.application.config.private_environment

  helper_method :logged_in?
  helper_method :current_user

  before_action :check_authentication
  before_action :set_raven_context

  rescue_from ActionController::ParameterMissing, with: :render_flash_error

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

  def set_raven_context
    if logged_in?
      Raven.user_context(
        id: current_user[:id],
        name: current_user[:name]
      )
    end
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
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

  def render_flash_error(error)
    flash[:notice] = error.original_message.capitalize
    redirect_to request.referrer if request.referrer
  end
end
