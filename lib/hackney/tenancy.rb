module Hackney
  class Tenancy
    include ActiveModel::Validations

    attr_accessor :ref, :current_balance, :type, :start_date, :primary_contact,
                  :address, :transactions, :agreements, :arrears_actions,
                  :scheduled_actions

    validates :ref, :current_balance, :type, :start_date, :primary_contact,
              :address, :transactions, :agreements, :arrears_actions,
              presence: true
  end
end
