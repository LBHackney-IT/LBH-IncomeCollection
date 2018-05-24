module Hackney
  class SmsTemplate
    include ActiveModel::Validations

    def initialize(id: nil, name: nil, body: nil)
      self.id = id
      self.name = name
      self.body = body
    end

    attr_accessor :id, :name, :body
    validates :id, :name, :body, presence: true
  end
end
