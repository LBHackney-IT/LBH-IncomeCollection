module Hackney
  module Models
    class Tenancy < ApplicationRecord
      has_many :tenancy_events, dependent: :destroy
      belongs_to :assigned_user, class_name: 'Hackney::Models::User', optional: true
    end
  end
end
