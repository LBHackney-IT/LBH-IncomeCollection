require 'rails_helper'

describe TenancyHelper do
  context '#tenancy_type_name' do
    it 'should return the name of a tenancy type' do
      expect(helper.tenancy_type_name('SEC')).to eq('Secure')
    end

    it 'should fail gracefully if it receives an unknown tenancy type' do
      expect(helper.tenancy_type_name('LOL')).to eq('LOL')
    end
  end
end
