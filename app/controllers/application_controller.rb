class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: ENV['BASIC_AUTH_USERNAME'], password: ENV['BASIC_AUTH_PASSWORD'] if Rails.application.config.private_environment

  attr_reader :current_user

  helper_method :logged_in?
  helper_method :current_user

  before_action :check_authentication
  before_action :set_raven_context

  rescue_from ActionController::ParameterMissing, with: :render_flash_error

  protected

  def use_cases
    @use_cases ||= Hackney::Income::UseCaseFactory.new
  end

  def current_user_id
    current_user.id
  end

  private

  def check_authentication
    return if logged_in?

    redirect_to login_path
  end

  def read_hackney_token
    @current_user if @current_user.present?

    raw_hackney_token = cookies['hackneyToken']

    return if raw_hackney_token.blank?

    payload = JWT.decode(
      raw_hackney_token, ENV['HACKNEY_JWT_SECRET'], true, algorithm: 'HS256'
    ).first

    @current_user = Hackney::Income::Domain::User.new.tap do |u|
      u.id = payload['sub']
      u.name = payload['name']
      u.email = payload['email']
      u.groups = payload['groups']
    end

  rescue JWT::DecodeError => e
    Rails.logger.warn "Error decoding JWT Token: #{e.message}"

    @current_user = nil
  end

  def set_raven_context
    if logged_in?
      Raven.user_context(
        id: current_user_id,
        name: current_user.name
      )
    end
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def logged_in?
    read_hackney_token

    current_user.present?
  end

  def render_flash_error(error)
    flash[:notice] = error.original_message.capitalize
    redirect_to request.referrer if request.referrer
  end
end
