class DocumentsController < ApplicationController
  def show
    document = use_cases.download_document.execute(id: params.require(:id))

    if document.code == 404
      flash[:notice] = 'Document not found'
      redirect_to documents_path
    else
      options = {
        content_type: document.content_type,
        status: document.code
      }

      options[:disposition]   = 'inline' if params[:inline]
      options[:disposition] ||= document['Content-Disposition']

      send_data(document.body, options)
    end
  end

  def index
    @documents = use_cases.get_all_documents.execute(filters: filters_param)
  end

  private

  def filters_param
    { payment_ref: params.fetch(:payment_ref, nil) }
  end
end
