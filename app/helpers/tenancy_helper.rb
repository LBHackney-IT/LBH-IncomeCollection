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

  def pause_reasons
    {
      'Court date set'     => 'CDS',
      'Eviction date set'  => 'EDS',
      'Delayed benefit'    => 'MBH',
      'Promise of payment' => 'POP',
      'Deceased'           => 'DEC',
      'Other'              => 'GEN'
    }
  end

  def action_diary_comment(comment)
    if comment.length > 100
      <<~HTML
        #{comment.slice!(truncate_comment(comment))}...
        <details class="govuk-details" data-module="govuk-details">
          <summary class="govuk-details__summary">
            <span class="govuk-details__summary-text">
              Continue reading
            </span>
          </summary>
          <div class="govuk-details__text">#{comment}</div>
        </details>
        HTML
      .html_safe
    else
      comment.html_safe
    end
  end

  private

  def truncate_comment(comment)
    truncate(
      comment,
      length: 100,
      omission: '',
      separator: ' ',
      escape: false
    )
  end
end
