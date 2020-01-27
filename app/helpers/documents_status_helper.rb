module DocumentsStatusHelper
  def status_map
    {
      uploading: 'Uploading',
      received: 'Received',
      accepted: 'Accepted',
      'validation-failed' => 'Validation Failed',
      downloaded: 'Downloaded',
      queued: 'Queued',
      failure_reviewed: 'Failure Reviewed'
    }
  end

  def status_dropdown_options(selected: nil)
    options = status_map.map { |db_name, human_name| [human_name, db_name] }

    options_for_select(options, selected)
  end
end
