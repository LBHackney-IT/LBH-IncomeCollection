module Hackney
  module Income
    class TemplateReplacer
      def replace(string, variables)
        string.gsub(PARENS_REGEXP) { |match| variables[match.slice(2..-3)] }
      end

      private

      PARENS_REGEXP = /\(\(([^\(]{1}[^\)]*)\)\)/.freeze
    end
  end
end
