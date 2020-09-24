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

  def if_outcome_needs_eviction_date(outcome)
    outcome == ('OPD' || 'OPF')
  end
end
