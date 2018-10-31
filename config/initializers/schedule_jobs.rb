if defined?(Rails::Server)
  # This sets up these scheduled tasks for the first time if they haven't already been queued, when booting the application server.

  # FIXME: This file will also need to be moved to the IC API
  Delayed::Worker.logger = ActiveSupport::Logger.new(STDOUT)
end
