class DocumentsController < ApplicationController
  def show
    response = use_cases.download_document.execute(id: params.require(:id))

    if response[:status_code] == 404
      flash[:notice] = 'Document not found'
      redirect_to letters_new_path
    else
      send_data response.body, filename: 'needs_a_proper_name.pdf'
    end
  end
end

