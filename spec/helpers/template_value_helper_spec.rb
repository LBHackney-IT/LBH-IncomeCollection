require 'rails_helper'

describe Hackney::TemplateValueHelper do
  let(:tenancy) { Hackney::Income::StubTenancyGatewayBuilder.build_stub.new.get_tenancy(tenancy_ref: '1234567') }

  context '#fill_in_values' do
    it 'should fill in the defined values' do
      expect(described_class.fill_in_values(TEMPLATE_WITH_ALL_FIELDS, tenancy)).to eq('Mr Clark Kent Mr Clark Kent Mr Kent')
    end
  end

  private

  TEMPLATE_WITH_ALL_FIELDS = [
    '((title))',
    '((first name))',
    '((last name))',
    '((full name))',
    '((formal name))'
  ].join(' ')
end
