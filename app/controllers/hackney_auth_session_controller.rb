class HackneyAuthSessionController < ApplicationController
  skip_before_action :check_authentication

  def new
    redirect_to worktray_path if logged_in?
  end

  def destroy
    cookies.delete('hackneyToken', domain: '.hackney.gov.uk', path: '/')

    redirect_to :root
  end
end
