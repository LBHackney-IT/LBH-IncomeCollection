module Hackney
  module Income
    class ListLetterTemplates
      def initialize(letters_gateway:)
        @letters_gateway = letters_gateway
      end

      def execute
        @letters_gateway.get_letter_templates.map do |template|
          LetterTemplate.new(
            id: template.fetch(:id),
            name: template.fetch(:name)
          )
        end
      end
    end
  end
end
