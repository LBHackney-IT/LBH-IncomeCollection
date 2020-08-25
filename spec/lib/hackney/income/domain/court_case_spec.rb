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
  let(:strike_out_date) { nil }

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

    context 'when the court date is nil and outcome is suspended on terms' do
      let(:court_date) { nil }
      let(:court_outcome) { described_class::CourtOutcomeCodes::SUSPENSION_ON_TERMS }

      it 'is expied' do
        expect(subject.expired?).to be_falsy
      end
    end

    describe '#adjourned?' do
      context 'When its an adjourned outcome' do
        let(:court_outcome) do
          [
            described_class::CourtOutcomeCodes::ADJOURNED_GENERALLY_WITH_PERMISSION_TO_RESTORE,
            described_class::CourtOutcomeCodes::ADJOURNED_TO_NEXT_OPEN_DATE,
            described_class::CourtOutcomeCodes::ADJOURNED_TO_ANOTHER_HEARING_DATE,
            described_class::CourtOutcomeCodes::ADJOURNED_FOR_DIRECTIONS_HEARING
          ].sample
        end

        it 'returns true' do
          expect(subject.adjourned?).to be_truthy
        end
      end

      context 'When its not an adjourned outcome' do
        let(:court_outcome) do
          [
            described_class::CourtOutcomeCodes::SUSPENSION_ON_TERMS,
            described_class::CourtOutcomeCodes::STRUCK_OUT,
            described_class::CourtOutcomeCodes::WITHDRAWN_ON_THE_DAY,
            described_class::CourtOutcomeCodes::STAY_OF_EXECUTION
          ].sample
        end

        it 'returns false' do
          expect(subject.adjourned?).to be_falsy
        end
      end
    end
  end
end
