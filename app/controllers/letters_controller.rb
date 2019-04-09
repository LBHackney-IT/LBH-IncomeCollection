class LettersController < ApplicationController
  def new
    @letter_templates = use_cases.list_letter_templates.execute
  end

  def preview
    @preview = use_cases.get_letter_preview.execute(
      template_id: params.require(:template_id),
      pay_ref: params.require(:pay_ref),
      user_id: session[:current_user].fetch('id')
    )
    flash[:notice] = 'Payment reference not found' if @preview[:status_code] == 404
    redirect_to letters_new_path if @preview[:status_code] == 404
  end

  def send_letter
    response = use_cases.send_letter.execute(
      uuid: params.require(:uuid),
      user_id: session[:current_user].fetch('id')
    )

    flash[:notice] = 'Successfully sent' if response.code.to_i == 204

    redirect_to letters_new_path
  end

  def show
    response = use_cases.download_letter.execute(id: params.require(:id))

    if response[:status_code] == 404
      flash[:notice] = 'Document not found'
      redirect_to letters_new_path
    else
      byebug
      send_data response.body, filename: 'needs_a_proper_name.pdf'
    end
  end
end
