require 'selenium/webdriver'
require 'capybara/rspec'

# Use `:selenium_chrome` for Header version
Capybara.javascript_driver = :selenium_chrome_headless

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    "goog:chromeOptions": {
      args: %w[headless disable-gpu window-size=1280,2000 no-sandbox allow-insecure-localhost]
    }
  )

  Capybara::Selenium::Driver.new app,
                                 browser: :chrome,
                                 desired_capabilities: capabilities
end
# Use `js: true` to use Headless Chrome on a context/describe
# Include `, driver: :selenium_chrome` to use Chrome in Head mode to help
# debug.
