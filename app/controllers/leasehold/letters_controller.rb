module Leasehold
  class LettersController < ApplicationController
    protect_from_forgery with: :null_session

    def new
      @letter_templates = use_cases.list_letter_templates.execute(
        user: current_user
      )
    end

    def preview
      @payment_refs = payment_refs
      @payment_refs.each_with_index do |payment_ref, i|
        @preview = generate_letter_preview(payment_ref)

        next unless @preview[:preview].present?

        @payment_refs.delete_at(i)
        @preview[:sendable] = @preview.dig(:template, :id) != 'letter_before_action'
        return @preview
      end

      flash[:notice] = 'Payment reference not found' if payment_refs_not_found?
      redirect_to leasehold_letters_new_path if payment_refs_not_found?
    end

    def ajax_preview
      @preview = generate_letter_preview(params.require(:pay_ref))

      head(@preview[:status_code]) if @preview[:status_code]

      @preview[:sendable] = @preview.dig(:template, :id) != 'letter_before_action'

      respond_to do |format|
        format.js
      end
    end

    def send_letter
      @letter_uuid = params.require(:uuid)

      sent_letter = use_cases.send_letter.execute(
        uuid: @letter_uuid,
        user: current_user,
        tenancy_ref: nil
      )

      respond_to do |format|
        if sent_letter.code.to_i == 204
          format.html { redirect_to leasehold_letters_new_path, notice: 'Successfully sent' }
          format.js   {}
        end
      end
    end

    private

    def payment_refs_not_found?
      !@preview[:preview].present? || @payment_refs.empty? || @preview[:status_code] == 404
    end

    def generate_letter_preview(payment_ref)
      use_cases.get_letter_preview.execute(
        template_id: params.require(:template_id),
        pay_ref: payment_ref,
        user: current_user
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
end
