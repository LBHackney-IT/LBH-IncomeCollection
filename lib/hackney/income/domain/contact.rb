module Hackney
  module Income
    module Domain
      class Contact
        attr_accessor :contact_id, :email_address, :uprn, :address_line_1,
                      :address_line_2, :address_line_3, :first_name, :last_name,
                      :full_name, :larn, :telephone_1, :telephone_2, :telephone_3,
                      :cautionary_alert, :property_cautionary_alert, :house_ref,
                      :title, :full_address_display, :full_address_search,
                      :post_code, :date_of_birth, :hackney_homes_id
      end
    end
  end
end
