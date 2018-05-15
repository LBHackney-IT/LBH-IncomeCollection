require 'rails_helper'

describe ContactHelper do
  let(:contact) { { title: 'Ms', first_name: 'Dana', last_name: 'Scully' } }

  context '#contact_name' do
    it 'should create a full name from a contact' do
      expect(helper.contact_name(contact)).to eq('Ms Dana Scully')
    end
  end
end
