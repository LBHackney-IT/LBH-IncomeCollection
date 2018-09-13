module PriorityHelper
  def display_priority_value(value)
    return 'NO' if value == false
    return 'YES' if value == true
    value.to_s
  end

  def display_priority_adjustment(value)
    return "+#{value}" if value.is_a?(Integer) && value.positive?
    return value.to_s if value.is_a?(Integer) && value.negative?
    'N/A'
  end

  def sorted_priority_criteria(criteria)
    criteria.sort_by { |c| c[:adjustment]&.to_f || 0.0 }.reverse
  end
end
