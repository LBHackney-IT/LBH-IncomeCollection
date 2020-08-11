module TenancyHelper
  BASIC_RENT_TRANSACTION_TYPE = 'DBR'.freeze

  def tenancy_type_name(tenancy_type)
    case tenancy_type
    when 'SEC' then 'Secure'
    else tenancy_type
    end
  end

  def tenancy_has_responsibile_tenant_with_email?(tenancy)
    tenancy.contacts.any? { |c| c[:responsible] && c[:email_address].present? }
  end

  def pause_reasons
    {
      'Court date set' => 'CDS',
      'Eviction date set' => 'EDS',
      'Delayed benefit' => 'MBH',
      'Promise of payment' => 'POP',
      'Deceased' => 'DEC',
      'Missing Data' => 'RMD',
      'Other' => 'GEN'
    }
  end

  def transaction_is_payment_or_basic_rent_outgoing?(transaction)
    transaction[:type] == BASIC_RENT_TRANSACTION_TYPE || transaction[:value].negative?
  end

  def select_all_other_outgoing_charges(group_summary_list)
    group_summary_list.select { |i| i[:transaction] && !transaction_is_payment_or_basic_rent_outgoing?(i) }
  end

  def calculate_sum_of_all_other_outgoing_charges(group_summary_list)
    group_summary_list.select { |i| i[:transaction] && i[:type] != BASIC_RENT_TRANSACTION_TYPE && i[:value].positive? }.sum { |i| i[:value] }
  end

  def insert_document_links_to_action_diary(entry)
    document_url = 'documents?payment_ref='
    if entry.include?(document_url)
      entry.gsub!(/#{Regexp.quote(document_url)}/, request.base_url + '/\0') # prepend environment url to document url
      entry.gsub!(URI::DEFAULT_PARSER.make_regexp, '<a href="\0">\0</a>') # insert anchor tag
    end
    entry
  end

  def show_send_letter_one_button?(classification)
    allowed_classifications_for_sending_letter_one = %w[
      send_letter_one informal_breached_after_letter
    ]

    allowed_classifications_for_sending_letter_one.include?(classification)
  end

  def show_send_letter_two_button?(classification)
    allowed_classifications_for_sending_letter_two = %w[
      send_letter_two informal_breached_after_letter
    ]

    allowed_classifications_for_sending_letter_two.include?(classification)
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
