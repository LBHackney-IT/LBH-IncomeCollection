require 'rails_helper'

describe TimeHelper do
  context '#date_range' do
    subject { helper.date_range(date_range, options) }
    let(:date_range) { Date.parse('01/01/2019')..Date.parse('31/01/2019') }
    let(:options) { {} }

    context 'without options' do
      it { is_expected.to eq('Jan 1 — 31, 2019') }
    end

    context 'when given long format' do
      let(:options) { { format: :long } }

      it { is_expected.to eq('January 1 — 31, 2019') }
    end

    context 'when given custom separator as a symbol' do
      let(:options) { { separator: :to } }

      it { is_expected.to eq('Jan 1 to 31, 2019') }
    end

    context 'when given custom separator as a string' do
      let(:options) { { separator: '_' } }

      it { is_expected.to eq('Jan 1 _ 31, 2019') }
    end

    context 'when over two months' do
      let(:date_range) { Date.parse('01/01/2019')..Date.parse('01/02/2019') }

      it { is_expected.to eq('Jan 1 — Feb 1, 2019') }
    end

    context 'when over two years' do
      let(:date_range) { Date.parse('01/01/2019')..Date.parse('01/01/2020') }

      it { is_expected.to eq('Jan 1, 2019 — Jan 1, 2020') }
    end

    context 'when over two years and two months' do
      let(:date_range) { Date.parse('01/01/2019')..Date.parse('01/02/2020') }

      it { is_expected.to eq('Jan 1, 2019 — Feb 1, 2020') }
    end
  end
end
