module Hackney
  module Income
    module Domain
      class ActionDiaryEntry
        include ActiveModel::Validations

        attr_accessor :balance, :code, :type, :date, :comment, :universal_housing_username

        validates :balance, :code, :type, :date, :comment, :universal_housing_username,
                  presence: true

        def display_date
          Time.parse(date).to_formatted_s(:long_ordinal)
        end
      end
    end
  end
end
