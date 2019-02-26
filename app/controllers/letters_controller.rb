require 'time'

class LettersController < ApplicationController
  def new
    @letter_templates = use_cases.list_letter_templates.execute
  end

  def preview
    pp '-----'
    pp params
    pp '-----'
  end
end
