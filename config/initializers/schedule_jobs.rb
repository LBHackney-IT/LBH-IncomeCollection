if defined?(Rails::Server)
  # This sets up these scheduled tasks for the first time if they haven't already been queued, when booting the application server.

  Delayed::Worker.logger = ActiveSupport::Logger.new(STDOUT)
end
