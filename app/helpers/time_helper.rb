module TimeHelper
  def date_range(from_date, until_date, options = {})
    options.symbolize_keys!
    format = options[:format] || :short
    separator = options[:separator] || '—'

    month_names = if format.to_sym == :short
                    I18n.t('date.abbr_month_names')
                  else
                    I18n.t('date.month_names')
                  end

    from_day = from_date.day
    from_month = month_names[from_date.month]
    from_year = from_date.year
    until_day = until_date.day

    dates = { from_day: from_day }

    if from_date.month == until_date.month && from_date.year == until_date.year
      date_format = 'same_month'
      dates.merge!(until_day: until_day, month: from_month, year: from_year)
    else
      until_month = month_names[until_date.month]

      dates.merge!(from_month: from_month, until_month: until_month, until_day: until_day)

      if from_date.year == until_date.year
        date_format = 'different_months_same_year'
        dates[:year] = from_year
      else
        until_year = until_date.year

        date_format = 'different_years'
        dates[:from_year] = from_year
        dates[:until_year] = until_year
      end
    end

    I18n.t("date_range.#{format}.#{date_format}", dates.merge(sep: separator))
  end
end
