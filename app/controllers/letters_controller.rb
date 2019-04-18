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
    @letter_uuid = params.require(:uuid)
    response = use_cases.send_letter.execute(
      uuid: @letter_uuid,
      user_id: session[:current_user].fetch('id')
    )
    respond_to do |format|
      if response.code.to_i == 204
        format.html { redirect_to letters_new_path, notice: 'Successfully sent' }
        format.js   {}
      end
    end
end
