module IncomeCollection
  class LettersController < ApplicationController
    protect_from_forgery with: :null_session

    # The only way to get to index is refreshing the `#create` page. So redirect to `#new`.
    def index
      redirect_to new_income_collection_letter_path
    end

    def new
      @letter_templates = use_cases.list_letter_templates.execute(
        user: current_user
      )
    end

    def create
      respond_to do |format|
        format.html do
          @tenancy_refs = tenancy_refs
          @tenancy_refs.each_with_index do |tenancy_ref, i|
            @preview = generate_letter_preview(tenancy_ref)

            next if @preview[:preview].blank?

            @tenancy_refs.delete_at(i)
            @preview[:sendable] = true
            break @preview
          end

          if (@preview[:preview].blank? && @tenancy_refs.empty?) || @preview[:status_code] == 404
            flash[:notice] = 'Tenancy Reference not found'
            redirect_to new_income_collection_letter_path
          else
            render :preview, format: :html
          end
        end
        format.js do
          @preview = generate_letter_preview(params.require(:tenancy_ref))

          if @preview[:status_code]
            head(@preview[:status_code])
            return
          end

          @preview[:sendable] = true

          render :preview, format: :js
        end
      end
    end

    def send_letter
      @letter_uuid = params.require(:uuid)
      tenancy_ref = params.require(:tenancy_ref)

      sent_letter = use_cases.send_letter.execute(uuid: @letter_uuid, user: current_user, tenancy_ref: tenancy_ref)

      respond_to do |format|
        if sent_letter.code.to_i == 204
          format.html { redirect_to new_income_collection_letter_path, notice: 'Successfully sent' }
          format.js   {}
        end
      end
    end

    private

    def generate_letter_preview(tenancy_ref)
      use_cases.get_letter_preview.execute(
        template_id: params.require(:template_id),
        tenancy_ref: tenancy_ref,
        user: current_user
      )
    end

    def tenancy_refs
      params.require(:tenancy_refs)
        .split(/\n|\s+|,|;/)
        .map(&:strip)
        .reject(&:empty?)
        .uniq
    end
  end
end
