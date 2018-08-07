module Hackney
  module TemplateValueHelper
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
    module_function :fill_in_values

    private

    def formal_name(tenancy)
      [component_parts(tenancy)[0], component_parts(tenancy)[2]].join(' ')
    end

    def component_parts(tenancy)
      tenancy.primary_contact_name.split(' ')
    end

    module_function :component_parts
    module_function :formal_name
  end
end
