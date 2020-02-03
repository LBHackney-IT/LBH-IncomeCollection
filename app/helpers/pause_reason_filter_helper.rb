module PauseReasonFilterHelper
  def pause_reason_filter(option)
    options_for_select(
      {
        'Court date set'     => 'Court date set',
        'Eviction date set'  => 'Eviction date set',
        'Delayed benefit'    => 'Delayed benefit',
        'Promise of payment' => 'Promise of payment',
        'Deceased'           => 'Deceased',
        'Missing Data'       => 'Missing Data',
        'Other'              => 'Other'
      }, option
    )
  end
end
