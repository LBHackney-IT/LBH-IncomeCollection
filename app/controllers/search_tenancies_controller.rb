class SearchTenanciesController < ApplicationController
  before_action :sanitize_page_params, :no_cache

  def show
    @keyword = search_params[:keyword]
    @page = search_params[:page]
    @results = []
    @number_of_pages = 0

    return unless @keyword

    resp = use_cases.search_tenancies.execute(search_term: @keyword, page: @page)
    @results = resp[:results]
    @number_of_pages = resp[:number_of_pages]
  end

  private

  def search_params
    params.permit(:keyword, :page)
  end

  def sanitize_page_params
    params[:page] = params[:page].to_i
  end

  def no_cache
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end
end
