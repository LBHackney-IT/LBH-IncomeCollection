class StaticController < ApplicationController
  def homepage
    render status: 200, plain: 'hello Hackney!'
  end
end
