require_relative 'boot'

require 'rails/all'

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
    config.i18n.fallbacks = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Load code defined in the lib directory
    config.eager_load_paths << Rails.root.join('lib')

    def config.include_developer_data?
      Rails.env.development? || Rails.env.staging?
    end
  end
end
