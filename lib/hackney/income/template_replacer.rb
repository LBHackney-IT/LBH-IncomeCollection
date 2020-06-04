module Hackney
  module Income
    class TemplateReplacer
      PARENS_REGEXP = /\(\(([^\(]{1}[^\)]*)\)\)/.freeze
      private_constant :PARENS_REGEXP

      def replace(string, variables)
        string.gsub(PARENS_REGEXP) { |match| variables[match.slice(2..-3)] }
      end
    end
  end
end
