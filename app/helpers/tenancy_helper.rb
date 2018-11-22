module TenancyHelper
  def tenancy_type_name(tenancy_type)
    case tenancy_type
    when 'SEC' then 'Secure'
    else tenancy_type
    end
  end

  def tenancy_has_responsibile_tenant_with_email?(tenancy)
    tenancy.contacts.any? { |c| c[:responsible] && c[:email_address].present? }
  end
end
