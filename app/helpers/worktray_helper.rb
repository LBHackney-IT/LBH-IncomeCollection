module WorktrayHelper
  def show_immediate_actions_filter?
    tabs_to_hide_filter = %w[paused full_patch upcoming_court_dates upcoming_evictions]

    tabs_to_hide_filter.select { |filter| filter.in?(params.keys) }.empty?
  end
end
