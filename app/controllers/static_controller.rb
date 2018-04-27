class StaticController < ApplicationController
  def homepage
    render status: 200, plain: 'Deployed with CircleCI'
  end
end
