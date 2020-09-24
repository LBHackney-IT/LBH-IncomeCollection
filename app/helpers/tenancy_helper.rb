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
      'C19 Court Order Breached' => 'CVB',
      'Other' => 'GEN'
    }
  end

  def pause_reason_filter(option)
    options_for_select(
      pause_reasons.keys, option
    )
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
end
