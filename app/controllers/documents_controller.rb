class DocumentsController < ApplicationController
  def show
    document = use_cases.download_document.execute(id: params.require(:id))

    if document.code == 404
      flash[:notice] = 'Document not found'
      redirect_to documents_path
    else

      send_data document.body, content_type: document.content_type, disposition: document['Content-Disposition'], status: document.code
    end
  end

  def index
    @documents = use_cases.get_all_documents.execute(filters: filters_param)
    @filter_param = filters_param
  end

  private

  def filters_param
    { payment_ref: params.fetch(:payment_ref, nil) }
  end
end
