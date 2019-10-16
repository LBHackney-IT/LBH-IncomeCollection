module Hackney
  module Income
    class RecommendedActionsList
      def self.options
        ["First SMS",
          "Letter 1",
          "Letter 2",
          "Warning Letter",
          "NOSP",
          "Expired NOSP",
          "UC Payments",
          "Court date",
          "Eviction due",
          "No contact",
          "DD Changes",
          "Breach 1",
          "Breach 2",
          "No Action"]
      end

      def self.actions_dropdown_options
        res = []
        options.each do |opt|
          res << [opt]
        end

        res.sort_by { |i| i[0] }
      end
    end
  end
end
