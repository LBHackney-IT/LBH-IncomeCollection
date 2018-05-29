module Hackney
  module Models
    class TenancyEvent < ApplicationRecord
      belongs_to :tenancy
    end
  end
end
