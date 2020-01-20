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
      'Court date set'     => 'CDS',
      'Eviction date set'  => 'EDS',
      'Delayed benefit'    => 'MBH',
      'Promise of payment' => 'POP',
      'Deceased'           => 'DEC',
      'Missing Data'       => 'RMD',
      'Other'              => 'GEN'
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
end
