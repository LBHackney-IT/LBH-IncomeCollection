describe Hackney::Income::Domain::Agreement do
  let(:subject) do
    described_class.new(
      agreement_type: type,
      tenancy_ref: '12345/01',
      amount: '34',
      frequency: 'weekly',
      start_date: '17/08/2020',
      court_case_id: court_case_id
    )
  end

  let(:court_case_id) { nil }

  context 'when there is no type assigned' do
    let(:type) { nil }

    it 'current_step should be type' do
      expect(subject.current_step).to eq(:type)
    end

    it 'agreement should be invalid' do
      expect(subject.invalid?).to eq(true)
    end
  end

  context 'when type is formal' do
    let(:type) { 'formal' }

    it 'current_step should be type' do
      expect(subject.current_step).to eq('formal')
    end

    it 'agreement should be invalid' do
      expect(subject.invalid?).to eq(true)
    end

    context 'when there is a court_case_id set' do
      let(:court_case_id) { 1 }

      it 'agreement should be valid' do
        expect(subject.invalid?).to eq(false)
      end
    end
  end

  context 'when type is informal' do
    let(:type) { 'informal' }

    it 'current_step should be type' do
      expect(subject.current_step).to eq('informal')
    end

    it 'agreement should be valid' do
      expect(subject.invalid?).to eq(false)
    end
  end
end
