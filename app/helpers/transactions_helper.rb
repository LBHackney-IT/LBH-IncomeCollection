module TransactionsHelper
  def from_last_year_as_json(transactions)
    last_year = Date.today.monday - 5.year
    last_year_of_transactions = transactions.select do |_date_key, group_summary|
      group_summary.fetch(:num_of_transactions).positive? &&
        group_summary.fetch(:date_range).first >= last_year
    end

    last_year_of_transactions.map do |_date_key, group_summary|
      {
        description: "Summary for #{date_range(group_summary.fetch(:date_range))}",
        date: group_summary.fetch(:date_range).last.to_date,
        displayValue: "Incoming: #{number_to_currency(group_summary.fetch(:incoming), unit: '£')}, Outgoing: #{number_to_currency(group_summary.fetch(:outgoing), unit: '£')}",
        finalBalance: group_summary.fetch(:balance)
      }
    end.to_json.html_safe
  end

  def class_for_value(value)
    if value.positive?
      'positive'
    else
      'negative'
    end
  end

  def date_range(date_range)
    DateRangeFormatter.format(date_range.first, date_range.last, 'short')
  end
end
