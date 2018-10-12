class SearchTenanciesController < ApplicationController
  before_action :sanitize_page_params, :no_cache

  def show
    search_term = search_params[:search_term]
    page = search_params[:page]
    @results = use_cases.search_tenancies.execute(search_term: search_term, page: page)
  end

  private

  def search_params
    params.permit(:search_term, :page)
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
