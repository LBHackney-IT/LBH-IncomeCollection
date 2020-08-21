describe Hackney::Income::Domain::CourtCase do
  let(:subject) do
    described_class.new.tap do |c|
      c.court_date = court_date
      c.court_outcome = court_outcome
      c.strike_out_date = strike_out_date
    end
  end

  let(:court_date) { Date.today }
  let(:court_outcome) { nil }

  describe '#expired?' do
    context 'when the court case is beyond the strike_out_date' do
      let(:strike_out_date) { Date.today - 1.day }

      it 'is expied' do
        expect(subject.expired?).to be_truthy
      end
    end

    context 'when the court case is before the strike_out_date' do
      let(:strike_out_date) { Date.today + 1.day }

      it 'is not expied' do
        expect(subject.expired?).to be_falsy
      end
    end

    context 'when the outcome is suspended on terms' do
      let(:strike_out_date) { nil }
      let(:court_outcome) { described_class::CourtOutcomeCodes::SUSPENSION_ON_TERMS }

      context 'within its 6 years of life from court date' do
        let(:court_date) { Date.today - 5.years }
        it 'is not expired' do
          expect(subject.expired?).to be_falsy
        end
      end

      context 'beyond 6 years of its life from court date' do
        let(:court_date) { Date.today - 6.years }
        it 'is expired' do
          expect(subject.expired?).to be_truthy
        end
      end
    end
  end
end
