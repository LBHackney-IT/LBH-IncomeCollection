class SearchTenanciesController < ApplicationController
  before_action :sanitize_page_params, :cache_headers

  def show
    search_term = search_params[:search_term]
    page = search_params[:page]
    @first_name = search_params[:first_name]
    @last_name = search_params[:last_name]
    @address = search_params[:address]
    @post_code = search_params[:post_code]
    @tenancy_ref = search_params[:tenancy_ref]
    # byebug
    @results = use_cases.search_tenancies.execute(
      search_term: search_term,
      page: page,
      first_name: @first_name,
      last_name: @last_name,
      address: @address,
      post_code: @post_code,
      tenancy_ref: @tenancy_ref
    )
  end

  private

  def search_params
    defaults = {
      search_term: '',
      page: 1,
      first_name: '',
      last_name: '',
      address: '',
      post_code: '',
      tenancy_ref: ''
    }
    params.permit(
      :search_term,
      :page,
      :first_name,
      :last_name,
      :address,
      :post_code,
      :tenancy_ref
    ).reverse_merge(defaults)
  end

  def sanitize_page_params
    params[:page] = params.fetch(:page, 1).to_i
  end

  def cache_headers
    response.headers['Cache-Control'] = 'private, max-age=600'
  end
end
