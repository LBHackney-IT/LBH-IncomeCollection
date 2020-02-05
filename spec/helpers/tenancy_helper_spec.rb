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

  describe '#show_send_letter_one_button?' do
    subject { helper.show_send_letter_one_button?(classification) }

    context 'when the classification is `send_letter_one`' do
      let(:classification) { 'send_letter_one' }

      it { is_expected.to eq(true) }
    end

    context 'when the classification is `send_letter_two`' do
      let(:classification) { 'send_letter_two' }

      it { is_expected.to eq(false) }
    end

    context 'when the classification is `informal_breached_after_letter`' do
      let(:classification) { 'informal_breached_after_letter' }

      it { is_expected.to eq(true) }
    end
  end

  describe '#show_send_letter_two_button?' do
    subject { helper.show_send_letter_two_button?(classification) }

    context 'when the classification is `send_letter_two`' do
      let(:classification) { 'send_letter_two' }

      it { is_expected.to eq(true) }
    end

    context 'when the classification is `send_letter_one`' do
      let(:classification) { 'send_letter_one' }

      it { is_expected.to eq(false) }
    end

    context 'when the classification is `informal_breached_after_letter`' do
      let(:classification) { 'informal_breached_after_letter' }

      it { is_expected.to eq(true) }
    end
  end
end
