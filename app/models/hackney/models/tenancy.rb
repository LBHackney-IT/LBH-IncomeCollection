module Hackney
  module Models
    class Tenancy < ApplicationRecord
      has_many :tenancy_events
    end
  end
end
