class DocumentsController < ApplicationController
  def show
    response = use_cases.download_document.execute(id: params.require(:id))

    if response[:status_code] == 404
      flash[:notice] = 'Document not found'
      redirect_to documents_path
    else
      send_data response.body
    end
  end

  def index
    @documents = use_cases.get_all_documents.execute
  end
end

