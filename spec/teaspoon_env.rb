require 'selenium-webdriver'
# If you want to delegate the driver management to the webdrivers gem, you also need to require it here
# require 'webdrivers' # or 'webdrivers/chromedriver' to be more specific

Teaspoon.configure do |config|
  config.driver = :selenium
  # config.driver_options = {client_driver: :firefox}
  #
  # or if you install off master
  # `gem 'teaspoon', git:'https://github.com/jejacks0n/teaspoon.git', branch:master` 
  # you can get support for chrome headless
  #
  # config.driver_options = {
  #  client_driver: :chrome,
  #  selenium_options: {
  #    options: Selenium::WebDriver::Chrome::Options.new(args: ['headless', 'disable-gpu'])
  #  }
  # }

end
