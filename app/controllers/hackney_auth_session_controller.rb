class HackneyAuthSessionController < ApplicationController
  skip_before_action :check_authentication

  def show
    redirect_to worktray_path if logged_in?
  end

  def destroy
    cookies.delete('hackneyToken')

    redirect_to :root
  end
end
