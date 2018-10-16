class SearchTenanciesController < ApplicationController
  before_action :sanitize_page_params, :cache_headers

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
    params[:page] = params.fetch(:page, 1).to_i
  end

  def cache_headers
    response.headers['Cache-Control'] = 'private, max-age=600'
  end
end
