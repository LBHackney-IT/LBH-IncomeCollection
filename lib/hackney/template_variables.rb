module Hackney
  module TemplateVariables
    def variables_for(tenancy)
      {
        'title' => tenancy.primary_contact_name.split(' ')[0],
        'first name' => tenancy.primary_contact_name.split(' ')[1],
        'last name' => tenancy.primary_contact_name.split(' ')[2],
        'full name' => [
          tenancy.primary_contact_name
        ].join(' '),
        'formal name' => [
          tenancy.primary_contact_name.split(' ')[0],
          tenancy.primary_contact_name.split(' ')[2]
        ].join(' ')
      }
    end

    module_function :variables_for
  end
end
