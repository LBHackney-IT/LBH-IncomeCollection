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
  rescue Exceptions::IncomeApiError => e
    Raven.capture_exception(e)
    flash[:notice] = 'An error occurred while loading your worktray, this may be caused by an Universal Housing outage'
  end

  def show
    @previous_page_params = request.query_parameters[:page_params]
    @page_number = list_cases_params[:page]

    tenancy_ref = params.fetch(:id)
    @tenancy = use_cases.view_tenancy.execute(tenancy_ref: tenancy_ref)

    if FeatureFlag.active?('create_informal_agreements')
      @agreements = use_cases.view_agreements.execute(tenancy_ref: tenancy_ref)
      @agreement = @agreements.find { |agreement| agreement.current_state == 'live' }
    end

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

  TABS = %i[
    immediate_actions
    paused
    full_patch
    upcoming_evictions
    upcoming_court_dates
  ].freeze

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
      TABS.each do |tab|
        next unless read_cookie_filter.dig(:active_tab, :name) == tab.to_s

        permitted_params[tab] ||= 'true'
        permitted_params['page'] = read_cookie_filter.dig(:active_tab, :page)
        read_tab_specific_filter(permitted_params, tab)
      end
    end

    permitted_params
  end

  def set_filter_cookie
    request_params = params.permit(:page, :patch_code)
    active_tab_param = params.permit(TABS)

    filters = {
        active_tab: {
            name: nil,
            page: nil,
            filter: nil
        }
    }.merge(read_cookie_filter)

    filters[:patch_code] = request_params[:patch_code] unless request_params[:patch_code].nil?
    filters[:active_tab][:page] = request_params[:page] unless request_params[:page].nil?

    active_tab = find_active_tab(active_tab_param)
    tab_specific_filter = find_tab_specific_filter(active_tab)

    if active_tab_param.blank?
      filters[:active_tab][:name] ||= active_tab
      filters[:active_tab][:page] = set_page_number(request_params[:page], filters, tab_specific_filter)
      filters[:active_tab][:filter] = tab_specific_filter unless params.permit(:recommended_actions).blank?
    else
      filters[:active_tab] = {
          name: active_tab,
          page: set_page_number(request_params[:page], filters, tab_specific_filter),
          filter: tab_specific_filter
      }
    end

    cookies[:filters] = filters.to_json unless filters.blank?
  end

  def set_page_number(page, filters, tab_specific_filter)
    if tab_specific_filter[:value] && filters.dig(:active_tab, :filter)
      filters[:active_tab][:page] = page || 1 if tab_specific_filter[:value] != filters.dig(:active_tab, :filter).dig(:value)
    end

    filters[:active_tab][:page] ||= page || 1
  end

  def read_cookie_filter
    return JSON.parse(cookies[:filters]).deep_symbolize_keys! unless cookies[:filters].nil?

    {}
  end

  def find_active_tab(params)
    return :paused if params[:paused]
    return :full_patch if params[:full_patch]
    return :upcoming_evictions if params[:upcoming_evictions]
    return :upcoming_court_dates if params[:upcoming_court_dates]

    :immediate_actions
  end

  TAB_FILTERS = %i[recommended_actions pause_reason].freeze

  def find_tab_specific_filter(tab)
    tab_filter_params = params.permit(TAB_FILTERS)
    return { key: 'recommended_actions', value: tab_filter_params[:recommended_actions] } if tab == :immediate_actions
    return { key: 'pause_reason', value: tab_filter_params[:pause_reason] } if tab == :paused

    {}
  end

  def read_tab_specific_filter(permitted_params, tab)
    tab_specific_filter = read_cookie_filter.dig(:active_tab, :filter)
    return if tab_specific_filter.nil?

    permitted_params['recommended_actions'] = tab_specific_filter[:value] if tab == :immediate_actions
    permitted_params['pause_reason'] = tab_specific_filter[:value] if tab == :paused
  end
end
