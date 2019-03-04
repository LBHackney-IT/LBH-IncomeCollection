require 'time'

class LettersController < ApplicationController
  def new
    @letter_templates = use_cases.list_letter_templates.execute
  end

  def preview
    @preview = use_cases.get_letter_preview.execute(
      template_id: params[:template_id],
      pay_ref: params[:pay_ref],
      user_id: session[:current_user].fetch('id')
    )
  rescue Exceptions::IncomeApiError::NotFoundError
    flash[:notice] = 'Payment reference not found'
    redirect_to letters_new_path
  end
end
