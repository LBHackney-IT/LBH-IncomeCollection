module TransactionsHelper
  def from_last_four_weeks(transactions)
    transactions.select do |transaction|
      last_four_weeks = Date.today.monday - 4.weeks
      transaction.fetch(:date) >= last_four_weeks
    end
  end
end
