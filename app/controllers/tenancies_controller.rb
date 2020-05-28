require 'time'

class TenanciesController < ApplicationController
  include TenancyHelper

  before_action :set_filter_cookie, only: :index

  def index
    @filter_params = Hackney::Income::FilterParams::ListCasesParams.new(list_cases_params)
    response = use_cases.list_cases.execute(filter_params: @filter_params)

    @page_number = response.page_number
    @number_of_pages = response.number_of_pages
    @tenancies = valid_tenancies(response.tenancies)
    @showing_paused_tenancies = response.paused
    @page_params = request.query_parameters

    @tenancies = Kaminari.paginate_array(
      @tenancies, total_count: @filter_params.count_per_page * @number_of_pages
    ).page(@page_number).per(@filter_params.count_per_page)

    respond_to do |format|
      format.html {}
      format.json do
        render json: {
          tenancies: @tenancies,
          page: @page_number,
          number_of_pages: @number_of_pages
        }.to_json
      end
    end
  end

  def show
    @previous_page_params = request.query_parameters[:page_params]
    @page_number = list_cases_params[:page]

    tenancy_ref = params.fetch(:id)
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)

    render :show
  end

  def pause
    @pause_tenancy = use_cases.pause_tenancy.execute(tenancy_ref: params.fetch(:id))
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: params.fetch(:id))
  rescue Exceptions::IncomeApiError::NotFoundError
    flash[:notice] = 'This tenancy is not eligible for pausing'
    redirect_to tenancy_path(id: params.fetch(:id))
  end

  def update
    response = use_cases.update_tenancy.execute(
      username: current_user.name,
      tenancy_ref: params.fetch(:id),
      pause_reason: pause_reasons.key(params.fetch(:action_code)),
      pause_comment: params.fetch(:pause_comment),
      action_code: params.fetch(:action_code),
      is_paused_until_date: Time.strptime(params.fetch(:is_paused_until), '%Y-%m-%d')
    )

    flash[:notice] = response.code.to_i == 204 ? 'Successfully paused' : "Unable to pause: #{response.message}"

    redirect_to tenancy_path(id: params.fetch(:id))
  end

  private

  # FIXME: stop filtering here, improve contact details
  def valid_tenancies(tenancies)
    tenancies.select { |t| t.primary_contact_name.present? }
  end

  def list_cases_params
    permitted_params = params.permit(
      :page, :recommended_actions, :paused, :full_patch, :upcoming_evictions, :upcoming_court_dates,
      :patch_code, :pause_reason
    )

    if read_cookie_filter.present?
      permitted_params[:patch_code] ||= read_cookie_filter[:patch_code] if read_cookie_filter[:patch_code]
      permitted_params[:paused] ||= 'true' if read_cookie_filter[:active_tab] == 'paused'
    end

    permitted_params
  end

  def set_filter_cookie
    patch_code_param = params.permit(:patch_code)
    active_tab_param = params.permit(:paused, :full_patch, :upcoming_evictions, :upcoming_court_dates, :immediate_actions)

    filters = read_cookie_filter || {}

    filters[:patch_code] = patch_code_param[:patch_code] unless patch_code_param.blank?
    filters[:active_tab] = find_active_tab(active_tab_param) unless active_tab_param.blank?
    cookies[:filters] = filters.to_json unless filters.blank?
  end

  def read_cookie_filter
    JSON.parse(cookies[:filters]).deep_symbolize_keys! unless cookies[:filters].nil?
  end

  def find_active_tab(active_tab_param)
    return :paused if active_tab_param[:paused]
  end
end
