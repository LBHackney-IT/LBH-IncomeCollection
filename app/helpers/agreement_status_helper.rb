module AgreementStatusHelper
  def human_agreement_status(code)
    case code
    when '100' then 'First Check'
    when '200' then 'Live'
    when '299' then 'Suspect'
    when '300' then 'Breached'
    when '400' then 'Suspended'
    when '500' then 'Cancelled'
    when '600' then 'Complete'
    else 'None'
    end
  end
end
