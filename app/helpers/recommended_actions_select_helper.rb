module RecommendedActionsSelectHelper
  def recommended_actions_map
    {
      no_action: 'No Action',
      send_NOSP: 'Send NOSP',
      send_warning_letter: 'Send Warning Letter',
      send_letter_two: 'Send Letter One',
      send_letter_one: 'Send Letter Two',
      send_first_SMS: 'Send First SMS'
   }
  end

  def recommended_actions_dropdown_options(selected: nil)
    options = recommended_actions_map.map { |db_name, human_name| [human_name, db_name] }

    options_for_select(options, selected)
  end
end
