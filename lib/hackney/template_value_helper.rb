module Hackney
  module TemplateValueHelper
    module_function

    def fill_in_values(template_body, tenancy)
      Hackney::Income::TemplateReplacer.new.replace(
        template_body,
        'first name' => component_parts(tenancy)[1],
        'last name' => component_parts(tenancy)[2],
        'title' => component_parts(tenancy)[0],
        'full name' => tenancy.primary_contact_name,
        'formal name' => formal_name(tenancy)
      )
    end

    def formal_name(tenancy)
      [component_parts(tenancy)[0], component_parts(tenancy)[2]].join(' ')
    end

    def component_parts(tenancy)
      tenancy.primary_contact_name.split(' ')
    end
  end
end
