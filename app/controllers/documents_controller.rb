class DocumentsController < ApplicationController
  def show
    document = use_cases.download_document.execute(
      id: params.require(:id),
      username: current_user.name,
      documents_view: params[:documents_view]
    )

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
    response = use_cases.get_all_documents.execute(filters: filters_param)

    @page_number = response[:page_number]
    @number_of_pages = response[:number_of_pages]
    @documents = response[:documents]

    @documents = Kaminari.paginate_array(
      @documents, total_count: filters_param[:documents_per_page] * @number_of_pages
    ).page(@page_number).per(filters_param[:documents_per_page])
  end

  def review_failure
    @document = use_cases.review_document_failure.execute(document_id: params.require(:id))
    flash[:notice] = 'Successfully marked as reviewed'
  rescue Exceptions::IncomeApiError::NotFoundError
    flash[:notice] = "An error occurred while marking document #{params.require(:id)} as reviewed"
  ensure
    redirect_back fallback_location: documents_path
  end

  private

  def filters_param
    {
      payment_ref: params.fetch(:payment_ref, nil),
      page_number: params.fetch(:page, 1),
      documents_per_page: params.fetch(:per_page, 20)
    }
  end
end
