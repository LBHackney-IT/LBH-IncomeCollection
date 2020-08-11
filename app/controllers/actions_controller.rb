class ActionsController < ApplicationController
  REQUIRED_INDEX_PARAMS = %i[service_area_type].freeze
  include WorktrayHelper
  include TenancyHelper

  before_action :set_filter_cookie, only: :index

  def index
    @filter_params = Hackney::Income::FilterParams::ListCasesParams.new(list_filter_params)

    if service_area_type == 'leasehold'
      response = use_cases.list_actions.execute(service_area_type: service_area_type, filter_params: @filter_params)

      @page_number = response.page_number
      @number_of_pages = response.number_of_pages
      @actions = response.actions
      @showing_paused_tenancies = response.paused
      @page_params = request.query_parameters

      @tenancies = Kaminari.paginate_array(
        @actions, total_count: @filter_params.count_per_page * @number_of_pages
      ).page(@page_number).per(@filter_params.count_per_page)
    else
      redirect_to(worktray_path)
    end
  rescue Exceptions::IncomeApiError => e
    Raven.capture_exception(e)
    flash[:notice] = 'An error occurred while loading your worktray, this may be caused by an Universal Housing outage'
  end

  private

  def service_area_type
    params.require(REQUIRED_INDEX_PARAMS).first
  end
end
