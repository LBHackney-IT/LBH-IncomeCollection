module WorktrayHelper
  def show_immediate_actions_filter?(filter_params = params)
    tabs_to_hide_filter = %w[paused full_patch upcoming_court_dates upcoming_evictions]

    tabs_to_hide_filter.select { |filter| filter_params.send(filter) }.empty?
  end

  def worktray_title
    return 'Paused Case List' if params[:paused]
    return 'Full Patch List' if params[:full_patch]
    return 'Upcoming Evictions' if params[:upcoming_evictions]
    return 'Upcoming Court Dates' if params[:upcoming_court_dates]

    'Case Worktray'
  end

  TABS = %i[
    immediate_actions
    paused
    full_patch
    upcoming_evictions
    upcoming_court_dates
  ].freeze

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

  def list_filter_params
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
end
