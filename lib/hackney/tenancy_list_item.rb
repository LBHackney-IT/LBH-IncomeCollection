module Hackney
  class TenancyListItem
    include ActiveModel::Validations

    attr_accessor :address_1, :tenancy_ref, :current_balance, :primary_contact

    validates :address_1, :tenancy_ref, :current_balance, :primary_contact,
              presence: true
  end
end