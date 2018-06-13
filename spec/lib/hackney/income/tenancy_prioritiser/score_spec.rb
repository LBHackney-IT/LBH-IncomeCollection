describe Hackney::Income::TenancyPrioritiser::Score do
  let(:criteria) { Hackney::Income::TenancyPrioritiser::StubCriteria.new }
  let(:weightings) { Hackney::Income::TenancyPrioritiser::PriorityWeightings.new }

  subject { described_class.new(criteria, weightings) }

  context 'when assigning a score based on all criteria' do
    # FIXME: acceptance test(s) for composite score here or elsewhere?
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

    it 'considers difference in amount paid between payments' do
      weightings.payment_amount_delta = 1
      criteria.payment_amount_delta = -50

      expect(subject.payment_amount_delta).to eq(-50)
    end

    it 'applies no score modifier for a nil delta' do
      weightings.payment_amount_delta = 1
      criteria.payment_amount_delta = nil

      expect(subject.payment_amount_delta).to eq(0)
    end

    it 'applies the delta directly to the score, as a positive delta means paid less than previous payment' do
      weightings.payment_amount_delta = 1
      criteria.payment_amount_delta = 150

      expect(subject.payment_amount_delta).to eq(150)
    end

    it 'considers irregularity in payment date' do
      weightings.payment_date_delta = 5
      criteria.payment_date_delta = 3

      expect(subject.payment_date_delta).to eq(15)
    end

    it 'applies the date delta as if it was positve, as a longer or shorter gap between payments is irregular' do
      weightings.payment_date_delta = 5
      criteria.payment_date_delta = -4

      expect(subject.payment_date_delta).to eq(20)
    end

    it 'applies no score modifier if the date delta is nil' do
      weightings.payment_date_delta = 5
      criteria.payment_date_delta = nil

      expect(subject.payment_date_delta).to eq(0)
    end

    it 'applies a score addition to a broken agreement' do
      weightings.number_of_broken_agreements = 50
      criteria.number_of_broken_agreements = 1

      expect(subject.number_of_broken_agreements).to eq(50)
    end

    it 'applies greater penalties as the number of agreements gets higher' do
      weightings.number_of_broken_agreements = 50
      criteria.number_of_broken_agreements = 5

      expect(subject.number_of_broken_agreements).to eq(300)
    end

    it 'applies a score to having a live agreement' do
      weightings.active_agreement = -100
      criteria.active_agreement = true

      expect(subject.active_agreement).to eq(-100)
    end

    it 'will apply the live agreement weighting directly' do
      weightings.active_agreement = 100
      criteria.active_agreement = true

      expect(subject.active_agreement).to eq(100)
    end

    it 'will apply a score to having a broken court ordered agreement' do
      weightings.broken_court_order = 200
      criteria.broken_court_order = true

      expect(subject.broken_court_order).to eq(200)
    end

    it 'will not apply a score if broken agreements are not court-ordered' do
      weightings.broken_court_order = 300
      criteria.broken_court_order = false
      criteria.number_of_broken_agreements = 2

      expect(subject.broken_court_order).to eq(nil)
    end

    it 'will apply a score if there is a valid nosp' do
      weightings.nosp_served = 20
      criteria.nosp_served = true

      expect(subject.nosp_served).to eq(20)
    end

    it 'will apply a score if there is an active nosp' do
      weightings.active_nosp = 50
      criteria.active_nosp = true

      expect(subject.active_nosp).to eq(50)
    end

    it 'will apply active nosp score over valid nosp' do
      weightings.active_nosp = 100
      criteria.active_nosp = true
      weightings.nosp_served = 250
      criteria.nosp_served = true

      expect(subject.active_nosp).to eq(100)
      expect(subject.nosp_served).to eq(nil)
    end
  end
end
