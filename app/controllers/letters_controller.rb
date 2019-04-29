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

    flash[:notice] = 'Payment reference not found' if @preview[:status_code] == 404
    redirect_to letters_new_path if @preview[:status_code] == 404
  end

  def ajax_preview
    @preview = use_cases.get_letter_preview.execute(
      template_id: params.require(:template_id),
      pay_ref: params.require(:pay_ref),
      user_id: session[:current_user].fetch('id')
    )

    head(@preview[:status_code]) if @preview[:status_code]

    respond_to do |format|
      format.js
    end
  end

  def send_letter
    @letter_uuid = params.require(:uuid)
    user_id     = session[:current_user].fetch('id')

    sent_letter = use_cases.send_letter.execute(
      uuid: @letter_uuid,
      user_id: user_id
    )

    respond_to do |format|
      if sent_letter.code.to_i == 204
        format.html { redirect_to letters_new_path, notice: 'Successfully sent' }
        format.js   {}
      end
    end
  end

  private

  def payment_refs
    params.require(:pay_refs).split(',').map(&:strip)
  end
end
