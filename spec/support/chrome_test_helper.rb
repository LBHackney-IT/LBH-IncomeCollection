require 'selenium/webdriver'

# Use `:selenium_chrome` for Header version
Capybara.javascript_driver = :selenium_chrome_headless

# Use `js: true` to use Headless Chrome on a context/describe
# Include `, driver: :selenium_chrome` to use Chrome in Head mode to help
# debug.
