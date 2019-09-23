class SearchTenanciesController < ApplicationController
  before_action :sanitize_page_params, :cache_headers

  def show
    page = search_params[:page]
    @first_name = search_params[:first_name]
    @last_name = search_params[:last_name]
    @address = search_params[:address]
    @post_code = search_params[:post_code]
    @tenancy_ref = search_params[:tenancy_ref]


    @results = use_cases.search_tenancies.execute(
      page: page,
      first_name: @first_name,
      last_name: @last_name,
      address: @address,
      post_code: @post_code,
      tenancy_ref: @tenancy_ref
    )
    @number_of_pages = @results.dig(:number_of_pages)
    @tenancies = Kaminari.paginate_array(@results.dig(:tenancies)).page(params[:page]).per(20)
  end

  private

  def search_params
    params.permit(
      :page,
      :first_name,
      :last_name,
      :address,
      :post_code,
      :tenancy_ref
    )
  end

  def sanitize_page_params
    params[:page] = params.fetch(:page, 1).to_i
  end

  def cache_headers
    response.headers['Cache-Control'] = 'private, max-age=600'
  end
end
