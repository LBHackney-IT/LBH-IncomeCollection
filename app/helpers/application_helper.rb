module ApplicationHelper
  def worktray_tab_link_to(text, path, filter_param = nil, filter_params_list = params, columns_no = 1)
    identifier = text.downcase.gsub(/\s/, '')

    checked = nil
    checked = filter_params_list.send(filter_param) if filter_param
    checked = true if checked.nil?

    content_tag(:a, href: path, id: identifier, class: 'tab__link') do
      html = []
      html << tag(:input, id: "#{identifier}_tab", class: 'tab__input', type: 'radio', name: 'tabs', checked: checked)
      html << content_tag(:label, class: "tab__label tab__label--#{columns_no}-columns", for: "#{identifier}_tab") do
        text
      end
      safe_join(html)
    end
  end

  def worktray_table_columns(page_state)
    return ['Pause Reason', 'Pause Comment', 'Paused Until Date'] if page_state[:paused]

    table_columns = ['Last Action', 'Agreements']

    return table_columns << 'Upcoming Court Dates' if page_state[:upcoming_court_dates]
    return table_columns << 'Upcoming Eviction Dates' if page_state[:upcoming_evictions]

    table_columns << 'Next Recommended Action'
  end

  def format_date(date)
    return '' if date.nil?

    Date.parse(date).to_formatted_s(:long_ordinal)
  end

  def format_time(time)
    return '' if time.nil?

    DateTime.parse(time).strftime('%R')
  end

  def format_short_date(datetime)
    return '' if datetime.blank?

    datetime.to_date.to_formatted_s(:rfc822)
  end
end
