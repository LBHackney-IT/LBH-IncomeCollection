require 'notifications/client'

module ReadTemplateNameFromApiResponse
  attr_reader :name

  def initialize(notification)
    super
    @name = notification.fetch('name', nil)
  end
end

Notifications::Client::Template.prepend(ReadTemplateNameFromApiResponse)
