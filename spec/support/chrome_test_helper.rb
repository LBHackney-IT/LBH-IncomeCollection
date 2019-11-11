require 'selenium/webdriver'

###################################
# How to use:
###################################
#
# You need to use RSpec in your own shell. You cannot use this inside Docker.
#
# `require 'support/chrome_test_helper'` at the top of your feature test.
#
# Use `js: true` to use Headless Chrome on a context/describe
# Include `, driver: :selenium_chrome` to use Chrome in Head mode to help debug.
#
# E.g.: `scenario 'Testing something awesome', js: true, driver: :selenium_chrome do`
#
# Call `#pause` in your `scenario` to stop the test at a point so you can see
# how everything looks/debug.
#

# Use `:selenium_chrome` for Header version
Capybara.javascript_driver = :selenium_chrome_headless

def pause
  STDIN.gets
end
