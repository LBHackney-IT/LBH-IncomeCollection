class LettersController < ApplicationController
  def new
    @letter_templates = use_cases.list_letter_templates.execute
  end

  def preview
    @preview = use_cases.get_letter_preview.execute(
      template_id: params.fetch(:template_id),
      pay_ref: params.fetch(:pay_ref),
      user_id: session[:current_user].fetch('id')
    )
    if @preview[:status_code] == 404
      flash[:notice] = 'Payment reference not found'
      redirect_to letters_new_path
    end
  rescue ActionController::ParameterMissing
    flash[:notice] = 'Error fetching preview: Please enter a payment reference'
  end
end
