module Hackney
  module TemplateVariables extend self
    def variables_for(tenancy)
      {
        'title' => tenancy.dig(:primary_contact, :title),
        'first name' => tenancy.dig(:primary_contact, :first_name),
        'last name' => tenancy.dig(:primary_contact, :last_name),
        'full name' => [
          tenancy.dig(:primary_contact, :title),
          tenancy.dig(:primary_contact, :first_name),
          tenancy.dig(:primary_contact, :last_name)
        ].join(' '),
        'formal name' => [
          tenancy.dig(:primary_contact, :title),
          tenancy.dig(:primary_contact, :last_name)
        ].join(' ')
      }
    end
  end
end
