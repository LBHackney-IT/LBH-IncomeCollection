require 'rails_helper'

describe AgreementStatusHelper do
  context '#tenancy_type_name' do
    it 'should return the name of a tenancy type' do
      expect(helper.human_agreement_status('100')).to eq('First Check')
      expect(helper.human_agreement_status('200')).to eq('Live')
      expect(helper.human_agreement_status('299')).to eq('Suspect')
      expect(helper.human_agreement_status('300')).to eq('Breached')
      expect(helper.human_agreement_status('400')).to eq('Suspended')
      expect(helper.human_agreement_status('500')).to eq('Cancelled')
      expect(helper.human_agreement_status('600')).to eq('Complete')
    end

    it 'should fail gracefully if it receives an unknown tenancy type' do
      expect(helper.human_agreement_status('LOL')).to eq('None')
    end
  end
end
