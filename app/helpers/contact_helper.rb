module ContactHelper
  def contact_name(contact)
    [
      contact.fetch(:title),
      contact.fetch(:first_name),
      contact.fetch(:last_name)
    ].join(' ')
  end

  def sanitize_number(number)
    Phonelib.parse(number).sanitized
  end
end
