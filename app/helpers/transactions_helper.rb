module TransactionsHelper
  def from_last_four_weeks(transactions)
    transactions.select do |transaction|
      last_four_weeks = Date.today.monday - 4.weeks
      transaction.fetch(:date) >= last_four_weeks
    end
  end

  def from_last_year(transactions)
    transactions.select do |transaction|
      last_year = Date.today.monday - 1.year
      transaction.fetch(:date) >= last_year
    end
  end

  def display_amount(charge)
    charge.positive? ? format('£%.2f', charge) : format('-£%.2f', charge.abs)
  end
end
