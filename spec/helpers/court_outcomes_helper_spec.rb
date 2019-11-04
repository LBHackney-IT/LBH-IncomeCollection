require 'rails_helper'

describe CourtOutcomesHelper, type: :helper do
  describe '#court_outcome_for_code' do
    context 'when we have a valid code' do
      it 'returns a human-readable string' do
        expect(helper.court_outcome_for_code('AAH')).to eq('Adjourned to another hearing date')
      end
    end

    context 'when we have an invalid code' do
      it 'returns nil' do
        expect(helper.court_outcome_for_code('foo')).to be_nil
      end
    end

    context 'when the given code is nil' do
      it 'returns nil' do
        expect(helper.court_outcome_for_code(nil)).to be_nil
      end
    end
  end
end
