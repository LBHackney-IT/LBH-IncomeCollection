module Hackney
  module TemplateValueHelper
    def fill_in_values(template_body, tenancy)
      Hackney::Income::TemplateReplacer.new.replace(
        template_body,
        'first name' => tenancy.dig(:primary_contact, :first_name),
        'last name' => tenancy.dig(:primary_contact, :last_name),
        'title' => tenancy.dig(:primary_contact, :title),
        'full name' => full_name_and_title(tenancy),
        'formal name' => formal_name(tenancy)
      )
    end

    module_function :fill_in_values

    private

    def full_name_and_title(tenancy)
      [
        tenancy.dig(:primary_contact, :title),
        tenancy.dig(:primary_contact, :first_name),
        tenancy.dig(:primary_contact, :last_name)
      ].join(' ')
    end

    def formal_name(tenancy)
      [
        tenancy.dig(:primary_contact, :title),
        tenancy.dig(:primary_contact, :last_name)
      ].join(' ')
    end

    module_function :full_name_and_title
    module_function :formal_name
  end
end
