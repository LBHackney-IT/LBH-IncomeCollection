module Hackney
  module Models
    class Tenancy < ApplicationRecord
      has_many :tenancy_events
      belongs_to :assigned_user, class_name: 'Hackney::Models::User', optional: true
    end
  end
end
