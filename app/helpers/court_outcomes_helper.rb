module CourtOutcomesHelper
  def court_outcomes_map
    {
      'AAH' => 'Adjourned to another hearing date',
      'AGE' => 'Adjourned generally',
      'AOT' => 'Adjourned on Terms',
      'OPD' => 'Outright Possession (with Date)',
      'OPF' => 'Outright Possession (Forthwith)',
      'PPO' => 'Postponed Possession Order',
      'STR' => 'Struck out',
      'SUP' => 'Suspended Possession',
      'WOD' => 'Withdrawn on the day (arrears cleared)'
    }
  end

  def court_outcomes
    [
      'AGP' => 'Adjourned generally with permission to restore',
      'AND' => 'Adjourned to the next open date',
      'AAH' => 'Adjourned to another hearing date',
      'ADH' => 'Adjourned for directions hearing',
      'SOT' => 'Suspension on terms',
      'SOE' => 'Stay of Execution',
      'WIT' => 'Withdrawn on the day',
      'STO' => 'Struck out'
    ]
  end

  def court_outcome_for_code(code)
    court_outcomes_map[code]
  end
end
