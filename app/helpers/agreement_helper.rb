module AgreementHelper
  def frequency_of_payments
    {
      'Weekly' => 'weekly',
      'Fortnightly' => 'fortnightly',
      '4 weekly' => '4 weekly',
      'Calendar monthly' => 'monthly'
    }
  end

  def show_end_date(total_arrears:, start_date:, frequency:, amount:, initial_payment_amount: nil)
    return nil if total_arrears.nil? || start_date.nil? || frequency.nil? || amount.nil?

    total_arrears = BigDecimal(total_arrears.to_s) - BigDecimal(initial_payment_amount.to_s) if initial_payment_amount
    start_date = Date.parse(start_date)
    number_of_instalments = (BigDecimal(total_arrears.to_s) / BigDecimal(amount.to_s)).ceil - 1
    end_date = if frequency == 'weekly'
                 start_date + number_of_instalments.weeks
               elsif frequency == 'fortnightly'
                 start_date + (number_of_instalments * 2).weeks
               elsif frequency == '4 weekly'
                 start_date + (number_of_instalments * 4).weeks
               else
                 start_date + number_of_instalments.months
               end

    format_date(end_date.to_s)
  end
end
