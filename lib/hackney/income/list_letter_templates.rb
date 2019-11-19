module Hackney
  module Income
    class ListLetterTemplates
      def initialize(letters_gateway:)
        @letters_gateway = letters_gateway
      end

      def execute(user:)
        @letters_gateway.get_letter_templates(user: user).map do |template|
          LetterTemplate.new(
            id: template.fetch(:id),
            name: template.fetch(:name)
          )
        end.sort_by(&:id)
      end
    end
  end
end
