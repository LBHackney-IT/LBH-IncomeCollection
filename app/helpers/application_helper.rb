module ApplicationHelper
  def worktray_tab_link_to(text, path, filter_param = nil)
    identifier = text.downcase.gsub(/\s/, '')

    checked = nil
    checked = params.key?(filter_param) if filter_param
    checked = true if checked.nil?

    content_tag(:a, href: path, id: identifier, class: 'tab__link') do
      html = []
      html << tag(:input, id: "#{identifier}_tab", class: 'tab__input', type: 'radio', name: 'tabs', checked: checked)
      html << content_tag(:label, class: 'tab__label tab__label--2-columns', for: "#{identifier}_tab") do
        text
      end
      safe_join(html)
    end
  end
end
