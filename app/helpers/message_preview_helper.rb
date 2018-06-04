module MessagePreviewHelper
  def message_preview(message)
    simple_format(message).gsub(URI::DEFAULT_PARSER.make_regexp, '<a href="\0">\0</a>').html_safe
  end
end
