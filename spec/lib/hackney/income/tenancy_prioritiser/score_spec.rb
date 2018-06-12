describe Hackney::Income::TenancyPrioritiser::Score do
  let(:criteria) { Hackney::Income::TenancyPrioritiser::StubCriteria.new }
  let(:weightings) { Hackney::Income::TenancyPrioritiser::PriorityWeightings.new }

  subject { described_class.new(criteria: criteria, weightings: weightings) }

  context 'when assigning a score based on all criteria' do

  end

  context 'when examining the breakdown of individual contributions to score' do
    it 'contributes the balance' do
      weightings.balance = 1.2
      criteria.balance = 500.00

      expect(subject.balance).to eq(600)
    end

    it 'contributes more for a higher balance' do
      weightings.balance = 1.2
      criteria.balance = 1000.00

      expect(subject.balance).to eq(1200)
    end

    it 'barely contributes if the balance is very small' do
      weightings.balance = 1.2
      criteria.balance = 5.00

      expect(subject.balance).to eq(6)
    end

    it 'contributes debt age' do
      weightings.days_in_arrears = 1.5
      criteria.days_in_arrears = 10

      expect(subject.days_in_arrears).to eq(15)
    end

    it 'contributes more for long term debt' do
      weightings.days_in_arrears = 1.5
      criteria.days_in_arrears = 100

      expect(subject.days_in_arrears).to eq(150)
    end

    it 'contributes the days since last payment' do
      weightings.days_since_last_payment = 1
      criteria.days_since_last_payment = 10

      expect(subject.days_since_last_payment).to eq(10)
    end

    it 'considers days since last payment to be much more severe as weeks pass' do
      weightings.days_since_last_payment = 1
      criteria.days_since_last_payment = 30

      expect(subject.days_since_last_payment).to eq(120)
    end
  end
end
