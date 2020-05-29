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
        next unless read_cookie_filter.dig(:active_tab, :name) == p.to_s
        permitted_params[p] ||= 'true'
        permitted_params['page'] = read_cookie_filter.dig(:active_tab, :page)
        set_tab_specific_filter(permitted_params, read_cookie_filter.dig(:active_tab, :name))
      end
    end

    permitted_params
  end

  TABS = [
      {
          name: :paused,
          filter_key: :paused_reason
      }, {
          name: :immediate_actions,
          filter_key: :recommended_actions
      }, {
          name: :full_patch,
          filter_key: nil
      }, {
          name: :upcoming_evictions,
          filter_key: nil
      }, {
          name: :upcoming_court_dates,
          filter_key: nil
      }
  ].freeze

  def set_filter_cookie
    patch_code_param = params.permit(:patch_code)
    page_param = params.permit(:page)
    active_tab_param = params.permit(TABS.map { |t| t[:name] })

    filters = {
        # recommended_actions: '',
        # paused: '',
        # full_patch: '',
        # upcoming_evictions: '',
        # upcoming_court_dates: '',
        # patch_code: '',
        active_tab: {
            name: nil,
            page: nil,
            filter: nil
        }
    }.merge(read_cookie_filter)

    filters[:patch_code] = patch_code_param[:patch_code] unless patch_code_param.blank?

    filters[:active_tab][:page] = page_param[:page] unless page_param.blank?

    if active_tab_param.blank?
      filters[:active_tab][:name] ||= find_active_tab(active_tab_param)
      filters[:active_tab][:page] ||= page_param.blank? ? 1 : page_param[:page]
      filters[:active_tab][:filter] = find_tab_specific_filter(find_active_tab(active_tab_param)) unless params.permit(:recommended_actions).blank?
    else
      filters[:active_tab] = {
          name: find_active_tab(active_tab_param),
          page: page_param.blank? ? 1 : page_param[:page],
          filter: find_tab_specific_filter(find_active_tab(active_tab_param))
      }
    end

    cookies[:filters] = filters.to_json unless filters.blank?
  end

  def read_cookie_filter
    return JSON.parse(cookies[:filters]).deep_symbolize_keys! unless cookies[:filters].nil?
    {}
  end

  def find_active_tab(active_tab_param)
    return :paused if active_tab_param[:paused]
    return :full_patch if active_tab_param[:full_patch]
    return :upcoming_evictions if active_tab_param[:upcoming_evictions]
    return :upcoming_court_dates if active_tab_param[:upcoming_court_dates]
    :immediate_actions
  end

  def find_tab_specific_filter(tab)
    permitted_filters = params.permit(:recommended_actions, :pause_reason)
    return { key: 'recommended_actions', value: permitted_filters[:recommended_actions] } if tab == :immediate_actions
    return { key: 'pause_reason', value: permitted_filters[:pause_reason] } if tab == :paused
    {}
  end

  def set_tab_specific_filter(permitted_params, tab)
    return if read_cookie_filter.dig(:active_tab, :filter).nil?
    permitted_params['recommended_actions'] = read_cookie_filter.dig(:active_tab, :filter).dig(:value) if tab == 'immediate_actions'
  end
end
