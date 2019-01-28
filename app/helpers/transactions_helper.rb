module TransactionsHelper
  def from_last_four_weeks(transactions)
    transactions.select do |transaction|
      last_four_weeks = Date.today.monday - 4.weeks
      transaction.fetch(:week).first >= last_four_weeks
    end
  end

  def from_last_year(transactions)
    transactions.select do |transaction|
      last_year = Date.today.monday - 1.year
      transaction.fetch(:week).first >= last_year
    end
  end
end
