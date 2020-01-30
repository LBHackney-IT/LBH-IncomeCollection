module WorktrayHelper
  def show_immediate_actions_filter?
    tabs_to_hide_filter = %w[paused full_patch upcoming_court_dates upcoming_evictions]

    tabs_to_hide_filter.select { |filter| filter.in?(params.keys) }.empty?
  end

  def worktray_title
    return 'Paused Case List' if params[:paused]
    return 'Full Patch List' if params[:full_patch]
    return 'Upcoming Evictions' if params[:upcoming_evictions]
    return 'Upcoming Court Dates' if params[:upcoming_court_dates]

    'Case Worktray'
  end
end
