module Hackney
  module Models
    class Tenancy < ApplicationRecord
      belongs_to :assigned_user, class_name: 'Hackney::Models::User', optional: true
    end
  end
end
