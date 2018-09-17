module Hackney
  module Income
    module Domain
      class ActionDiaryEntry
        include ActiveModel::Validations

        attr_accessor :balance, :code, :type, :date, :comment, :universal_housing_username

        validates :balance, :code, :type, :date, :comment, :universal_housing_username,
                  presence: true

        def balance_with_precision
          ActionController::Base.helpers.number_with_precision(balance, precision: 2)
        end

        def display_date
          return date.to_s if date.is_a?(ActiveSupport::TimeWithZone)
          Time.parse(date).to_formatted_s(:long_ordinal)
        end
      end
    end
  end
end
