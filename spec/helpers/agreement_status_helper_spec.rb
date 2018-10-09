require 'rails_helper'

describe AgreementStatusHelper do
  context '#tenancy_type_name' do
    it 'should return the name of a tenancy type' do
      expect(helper.human_agreement_status('200')).to eq('Active')
      expect(helper.human_agreement_status('400')).to eq('Breached')
      expect(helper.human_agreement_status('300')).to eq('Inactive')
    end

    it 'should fail gracefully if it receives an unknown tenancy type' do
      expect(helper.human_agreement_status('LOL')).to eq('None')
    end
  end
end
