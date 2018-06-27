require 'rails_helper'

describe Hackney::Income::TenancyPrioritiser do
  let(:tenancy) { example_tenancy }
  let(:transactions) { [example_transaction] }
  let(:weightings) { Hackney::Income::TenancyPrioritiser::PriorityWeightings.new }
  let(:one_day_before_amber_debt_age_threshold) { 104.days }
  let(:one_day_before_red_debt_age_threshold) { 205.days }

  let(:subject) { described_class.new(tenancy: tenancy, transactions: transactions, weightings: weightings) }

  context 'when assigning a priority band to a case' do
    it 'passes the criteria to the band assignment' do
      expect_any_instance_of(Hackney::Income::TenancyPrioritiser::Band).to receive(:execute).with(
        criteria: instance_of(Hackney::Income::TenancyPrioritiser::Criteria)
      )

      subject.assign_priority_band
    end

    it 'can assign a band for the given tenancy' do
      expect(subject.assign_priority_band).to eq(:green)
    end
  end

  context 'when assigning a priority score to a case' do
    it 'passes the criteria to the score assignment' do
      expect_any_instance_of(Hackney::Income::TenancyPrioritiser::Score).to receive(:execute)

      subject.assign_priority_score
    end

    it 'can assign a composite score for a tenancy' do
      expect(subject.assign_priority_score).to eq(2)
    end
  end

  context 'when using the score to drive band changes in edge cases' do
    context 'a green case scores very highly' do
      let(:tenancy) { green_tenancy }
      let(:transactions) { [amber_threshold_transaction] }

      it 'reassigns to amber' do
        expect(subject.assign_priority_band).to eq(:green)
        expect(subject.assign_priority_score).to be > Hackney::Income::TenancyPrioritiser::AMBER_SCORE_THRESHOLD
        expect(subject.score_adjusted_band).to eq(:amber)
      end
    end

    context 'when a case is green but score would drive band to amber but maintaining an agreement' do
      let(:tenancy) { green_tenancy }
      let(:transactions) { [amber_threshold_transaction] }

      it 'stays green' do
        tenancy[:agreements] = [example_agreement(type: 'informal', status: 'active')]
        expect(subject.assign_priority_band).to eq(:green)
        expect(subject.score_adjusted_band).to eq(:green)
      end
    end

    context 'an amber case scores very highly' do
      let(:tenancy) { amber_tenancy }
      let(:transactions) { [red_threshold_transaction] }

      it 'reassigns to red' do
        expect(subject.assign_priority_band).to eq(:amber)
        expect(subject.assign_priority_score).to be > Hackney::Income::TenancyPrioritiser::RED_SCORE_THRESHOLD
        expect(subject.score_adjusted_band).to eq(:red)
      end
    end
  end

  def green_tenancy
    example_tenancy(
      current_balance: '349.00',
      agreements: []
    )
  end

  def amber_tenancy
    example_tenancy(
      current_balance: '1049.00',
      agreements: []
    )
  end

  def amber_threshold_transaction
    example_transaction(
      timestamp: Time.now - one_day_before_amber_debt_age_threshold
    )
  end

  def red_threshold_transaction
    example_transaction(
      timestamp: Time.now - one_day_before_red_debt_age_threshold
    )
  end
end
