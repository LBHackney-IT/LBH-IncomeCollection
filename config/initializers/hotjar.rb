Rails.application.config do |f|
  f.config.x.hotjar_key = ENV['HOTJAR_KEY']
  f.config.x.hotjar_version = ENV['HOTJAR_VERSION']
end
