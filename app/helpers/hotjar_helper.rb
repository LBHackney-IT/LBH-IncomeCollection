module HotjarHelper
  def hotjar_tags
    hotjar_key = Rails.application.config.x.hotjar_key
    hotjar_version = Rails.application.config.x.hotjar_version

    return '' if hotjar_key.blank? # disable hotjar

    content_tag(:script) do
      raw(
        '(function(h,o,t,j,a,r){' \
        'h.hj=h.hj||function(){(h.hj.q=h.hj.q||[]).push(arguments)};' \
        "h._hjSettings={hjid:#{hotjar_key},hjsv:#{hotjar_version}};" \
        "a=o.getElementsByTagName('head')[0];" \
        "r=o.createElement('script');r.async=1;" \
        'r.src=t+h._hjSettings.hjid+j+h._hjSettings.hjsv;' \
        'a.appendChild(r);' \
        "})(window,document,'https://static.hotjar.com/c/hotjar-','.js?sv=');"
      )
    end
  end
end
