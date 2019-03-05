module Hackney
  class LetterTemplate
    include ActiveModel::Validations

    def initialize(id: nil, name: nil)
      self.id = id
      self.name = name
    end

    attr_accessor :id, :name
    validates :id, :name, presence: true
  end
end
