require 'rails_helper'

describe Hackney::TemplateVariables do
  let(:tenancy) { Hackney::Income::StubTenancyGateway.new.get_tenancy(tenancy_ref: '1234567') }

  context '#variables_for' do
    it 'should fill in the defined values' do
      expect(described_class.variables_for(tenancy)).to include({
        "first name" => "Clark",
        "formal name" => "Mr Kent",
        "full name" => "Mr Clark Kent",
        "last name" => "Kent",
        "title" => "Mr",
      })
    end
  end
end
