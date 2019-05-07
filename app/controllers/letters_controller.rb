class LettersController < ApplicationController
  protect_from_forgery with: :null_session

  def new
    @letter_templates = use_cases.list_letter_templates.execute
  end

  def preview
    @preview = get_first_letter_preview
    @payment_refs = payment_ref_except @preview

    flash[:notice] = 'Payment reference not found' if payment_refs_not_found?
    redirect_to letters_new_path if payment_refs_not_found?
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

  def get_first_letter_preview
    payment_refs.each do |ref|
      preview = generate_letter_preview(ref)
      return preview if preview.present?
    end

    nil
  end

  def payment_ref_except(letter_preview)
    if letter_preview[:preview].present?
      payment_refs - [letter_preview[:case][:payment_ref]]
    else
      payment_refs
    end
  end

  def payment_refs_not_found?
    !@preview[:preview].present? || payment_refs.empty? || @preview[:status_code] == 404
  end

  def generate_letter_preview(payment_ref)
    use_cases.get_letter_preview.execute(
      template_id: params.require(:template_id),
      pay_ref: payment_ref,
      user_id: session[:current_user].fetch('id')
    )
  end

  def payment_refs
    params.require(:pay_refs)
      .split(/\n|\s+|,|;/)
      .map(&:strip)
      .reject(&:empty?)
      .uniq
  end
end
