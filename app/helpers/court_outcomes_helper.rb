module CourtOutcomesHelper
  def court_outcomes
    {
      'ADT' => 'Adjourned on Terms',
      'AGP' => 'Adjourned generally with permission to restore',
      'AND' => 'Adjourned to the next open date',
      'AAH' => 'Adjourned to another hearing date',
      'ADH' => 'Adjourned for directions hearing',
      'OPD' => 'Outright Possession (with Date)',
      'OPF' => 'Outright Possession (Forthwith)',
      'SOT' => 'Suspension on terms',
      'SOE' => 'Stay of Execution',
      'STO' => 'Struck out',
      'WIT' => 'Withdrawn on the day'
    }
  end

  def court_outcome_for_code(code)
    court_outcomes[code]
  end
end
