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
      %i[paused full_patch upcoming_evictions upcoming_court_dates immediate_actions].each do |p|
        if read_cookie_filter.dig(:active_tab, :name) == p.to_s
          permitted_params[p] ||= 'true'
          permitted_params['page'] = read_cookie_filter.dig(:active_tab, :page)
        end
      end
    end

    permitted_params
  end

  FILTERS = %i[paused full_patch upcoming_evictions upcoming_court_dates immediate_actions].freeze

  def set_filter_cookie
    patch_code_param = params.permit(:patch_code)
    page_param = params.permit(:page)
    active_tab_param = params.permit(FILTERS)

    filters = {
        # recommended_actions: '',
        # paused: '',
        # full_patch: '',
        # upcoming_evictions: '',
        # upcoming_court_dates: '',
        # patch_code: '',
        active_tab: {
            name: '',
            page: ''
        }
    }.merge(read_cookie_filter)

    filters[:patch_code] = patch_code_param[:patch_code] unless patch_code_param.blank?

    filters[:active_tab][:page] = page_param[:page] unless page_param.blank?

    unless active_tab_param.blank?
      filters[:active_tab] = {
          name: find_active_tab(active_tab_param),
          page: page_param.blank? ? 1 : page_param[:page]
      }
    end
    cookies[:filters] = filters.to_json unless filters.blank?
  end

  def read_cookie_filter
    return JSON.parse(cookies[:filters]).deep_symbolize_keys! unless cookies[:filters].nil?
    {}
  end

  def find_active_tab(active_tab_param)
    return :immediate_actions if active_tab_param[:immediate_actions]
    return :paused if active_tab_param[:paused]
    return :full_patch if active_tab_param[:full_patch]
    return :upcoming_evictions if active_tab_param[:upcoming_evictions]
    return :upcoming_court_dates if active_tab_param[:upcoming_court_dates]
  end
end
