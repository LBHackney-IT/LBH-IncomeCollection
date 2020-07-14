module AgreementHelper
  def frequency_of_payments
    {
      'Weekly' => 'Weekly',
      'Fortnightly' => 'Fortnightly',
      '4 weekly' => '4 weekly',
      'Calendar monthly' => 'Monthly'
    }
  end
end
