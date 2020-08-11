module RecommendedActionsSelectHelper
  def recommended_actions_map
    {
      no_action: 'No Action',
      check_data: 'Check Case Data',
      apply_for_court_date: 'Apply for Court Date (PCOL)',
      send_court_warning_letter: 'Send Court Warning Letter',
      send_NOSP: 'Send NOSP',
      send_letter_one: 'Send Letter One',
      send_letter_two: 'Send Letter Two',
      send_first_SMS: 'Send First SMS',
      update_court_outcome_action: 'Update Court Outcome',
      court_breach_no_payment: 'Court Breach - No Payment',
      court_breach_visit: 'Court Breach Visit',
      send_court_agreement_breach_letter: 'Send Court Agreement Breached Letter',
      send_informal_agreement_breach_letter: 'Send Informal Agreement Breached Letter',
      informal_breached_after_letter: 'Informal Agreement Breach Letter Sent & Still Breached',
      review_failed_letter: 'Review Failed Letter',
      apply_for_outright_possession_warrant: 'Apply for Outright Possession Warrant'
    }
  end

  def recommended_actions_dropdown_options(selected: nil)
    options = recommended_actions_map.map { |db_name, human_name| [human_name, db_name] }

    options_for_select(options, selected)
  end
end
