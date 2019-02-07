module TransactionsHelper
  def from_last_four_weeks(transactions)
    transactions.select do |transaction|
      last_four_weeks = Date.today.monday - 4.weeks
      transaction.fetch(:week).first >= last_four_weeks
    end
  end

  def from_last_year_as_json(transactions)
    last_year = Date.today.monday - 1.year
    last_year_of_transactions = transactions.select { |transaction| transaction.fetch(:week).first >= last_year }

    last_year_of_transactions.map do |t|
      {
        description: "Summary for #{date_range(t.fetch(:week))}",
        date: t.fetch(:week).last,
        displayValue: "Incoming: #{number_to_currency(t.fetch(:incoming), unit: '£')}, Outgoing: #{number_to_currency(t.fetch(:outgoing), unit: '£')}",
        finalBalance: t.fetch(:final_balance)
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
