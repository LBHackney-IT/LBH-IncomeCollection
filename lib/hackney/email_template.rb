module Hackney
  class EmailTemplate
    include ActiveModel::Validations

    def initialize(id: nil, name: nil, body: nil, subject: nil)
      self.id = id
      self.name = name
      self.body = body
      self.subject = subject
    end

    attr_accessor :id, :name, :body, :subject
    validates :id, :name, :body, :subject, presence: true
  end
end
