module AgreementHelper
  def frequency_of_payments
    {
      'Weekly' => 'weekly',
      'Fortnightly' => 'fortnightly',
      '4 weekly' => '4 weekly',
      'Calendar monthly' => 'monthly'
    }
  end

  def show_end_date(total_arrears:, start_date:, frequency:, amount:)
    return nil if total_arrears.nil? || start_date.nil? || frequency.nil? || amount.nil?

    start_date = Date.parse(start_date)
    number_of_instalments = total_arrears.to_f.fdiv(amount.to_f).ceil - 1
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
