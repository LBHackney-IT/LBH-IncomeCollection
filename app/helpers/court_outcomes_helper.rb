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
      'Adjourned generally with liberty/permission to restore',
      'Adjourned to the next open date',
      'Adjourned to another hearing date',
      'Adjourned for directions hearing',
      'Adjourned on terms',
      'Suspension on terms',
      'Stay of Execution'
    ]
  end

  def court_outcome_for_code(code)
    court_outcomes_map[code]
  end
end
