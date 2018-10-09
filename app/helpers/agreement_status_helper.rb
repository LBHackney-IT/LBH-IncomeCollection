module AgreementStatusHelper
  def human_agreement_status(code)
    case code
    when '200' then 'Active'
    when '400' then 'Breached'
    when '300' then 'Inactive'
    else 'None'
    end
  end
end
