class HackneyAuthSessionController < ApplicationController
  skip_before_action :check_authentication

  def new
    redirect_to worktray_path if logged_in?
  end

  def destroy
    cookie_options = { domain: '.hackney.gov.uk', path: '/' }
    cookie_options = {} if Rails.env.development?

    cookies.delete('hackneyToken', cookie_options)

    redirect_to :root
  end
end
