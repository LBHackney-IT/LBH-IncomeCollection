module Hackney
  module Income
    module Domain
      class ActionDiaryEntry
        include ActiveModel::Validations

        attr_accessor :balance, :code, :type, :date, :comment, :universal_housing_username

        validates :balance, :code, :type, :date, :comment, :universal_housing_username,
                  presence: true
      end
    end
  end
end
