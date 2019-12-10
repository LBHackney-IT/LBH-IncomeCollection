module RecommendedActionsSelectHelper
  def recommended_actions_map
    {
      no_action: 'No Action',
      apply_for_court_date: 'Apply for Court Date (PCOL)',
      send_court_warning_letter: 'Send Court Warning Letter',
      send_NOSP: 'Send NOSP',
      send_letter_one: 'Send Letter One',
      send_letter_two: 'Send Letter Two',
      send_first_SMS: 'Send First SMS'
   }
  end

  def recommended_actions_dropdown_options(selected: nil)
    options = recommended_actions_map.map { |db_name, human_name| [human_name, db_name] }

    options_for_select(options, selected)
  end
end
