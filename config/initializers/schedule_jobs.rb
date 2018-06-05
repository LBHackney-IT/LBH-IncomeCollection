if defined?(Rails::Server)
  # Scheduled tasks like SyncTenanciesJob should automatically re-queue their next run, if necessary.
  # This sets up these scheduled tasks for the first time if they haven't already been queued, when booting the application server.

  Delayed::Worker.logger = ActiveSupport::Logger.new(STDOUT)

  SyncTenanciesJob.perform_later if Delayed::Job.where('handler LIKE :condition', condition: '%job_class: SyncTenanciesJob%').none?
end
