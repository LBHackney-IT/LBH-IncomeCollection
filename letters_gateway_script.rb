require 'pp'

INCOME_API_HOST = ENV['INCOME_COLLECTION_LIST_API_HOST']

letters_gateway = Hackney::Income::LettersGateway.new(
  api_host: INCOME_API_HOST,
  api_key: ENV.fetch('INCOME_COLLECTION_API_KEY')
)

list_letter_templates = Hackney::Income::ListLetterTemplates.new(
  letters_gateway: letters_gateway
)
puts "list_letter_templates: #{list_letter_templates}"

# templates = list_letter_templates.execute
# puts "templates: #{templates}"
# puts "Is array? #{templates.instance_of? Array}"

# templates.map { |template| puts template.inspect.to_s }

templates = letters_gateway.get_letter_templates.map do |template|
  Hackney::LetterTemplate.new(
    id: template.fetch(:id),
    name: template.fetch(:name)
  )
end.sort_by(&:id)

PP.pp(templates, $DEFAULT_OUTPUT, 40)
puts "Is array? #{templates.instance_of? Array}"

# sorted = templates.sort_by(&:id)
# PP.pp(sorted, $DEFAULT_OUTPUT, 40)
# puts "Is array? #{sorted.instance_of? Array}"
