require_relative 'boot'
require 'net/http'

# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
# require "active_record/railtie"
require 'action_cable/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    config.private_environment = true

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
    # the I18n.default_locale when a translation cannot be found).
    config.i18n.fallbacks = [I18n.default_locale]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Load code defined in the lib directory
    config.eager_load_paths << Rails.root.join('lib')

    config.x.hotjar_key = ENV['HOTJAR_KEY']
    config.x.hotjar_version = ENV['HOTJAR_VERSION']

    config.x.google_analytics_id = ENV['GOOGLE_ANALYTICS_ID']

    def config.include_developer_data?
      Rails.env.development? || Rails.env.staging?
    end
  end
end
