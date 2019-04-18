class LettersController < ApplicationController
  protect_from_forgery with: :null_session

  def new
    @letter_templates = use_cases.list_letter_templates.execute
  end

  def preview

    @payment_refs = payment_refs

    @preview = use_cases.get_letter_preview.execute(
      template_id: params.require(:template_id),
      pay_ref: @payment_refs.delete_at(0),
      user_id: session[:current_user].fetch('id')
    )
byebug
    respond_to do |format|
      format.html do
        flash[:notice] = 'Payment reference not found' if @preview[:status_code] == 404
        redirect_to letters_new_path if @preview[:status_code] == 404
      end
      format.js {}
    end
  end

  def send_letter
    response = use_cases.send_letter.execute(
      uuid: params.require(:uuid),
      user_id: session[:current_user].fetch('id')
    )

    flash[:notice] = 'Successfully sent' if response.code.to_i == 204

    redirect_to letters_new_path
  end

  private

  def payment_refs
    params.require(:pay_refs).split(',').collect(&:to_i)
  end
end
