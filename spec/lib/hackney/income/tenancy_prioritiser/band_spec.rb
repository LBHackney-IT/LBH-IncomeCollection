require 'rails_helper'

describe Hackney::Income::TenancyPrioritiser::Band do
  let(:criteria) { Hackney::Income::TenancyPrioritiser::StubCriteria.new }

  subject { described_class.new.execute(criteria: criteria) }

  context 'maintaining an agreement' do
    it 'will assign green while an active agreement is maintained regardless of other factors' do
      criteria.balance = 500.00
      criteria.days_in_arrears = 125

      criteria.days_since_last_payment = 6
      criteria.active_agreement = true

      expect(subject).to eq(:green)
    end
  end

  context 'assigning a tenancy to the red band' do
    it 'happens when balance is greater than £1050' do
      criteria.balance = 1050

      expect(subject).to eq(:red)
    end

    it 'happens when a court ordered repayment agreement is broken' do
      criteria.broken_court_order = true

      expect(subject).to eq(:red)
    end

    # FIXME: I think we should probably defensively filter agreements > 3 years old
    it 'happens when more than two agreements have been breached in the last three years and there is no live agreement' do
      criteria.number_of_broken_agreements = 3
      criteria.active_agreement = false

      expect(subject).to eq(:red)
    end

    it 'happens when debt age is greater than 30 weeks' do
      criteria.days_in_arrears = 31 * 7

      expect(subject).to eq(:red)
    end

    it 'happens when a valid nosp is present and no payment has been received in 28 days' do
      criteria.nosp_served = true
      criteria.days_since_last_payment = 29

      expect(subject).to eq(:red)
    end

    it 'happens when a valid nosp is present and no payment has ever been received' do
      criteria.nosp_served = true
      criteria.days_since_last_payment = nil

      expect(subject).to eq(:red)
    end

    context 'when payment pattern is erratic' do
      it 'will not factor this if the delta is nil, as there are too few payments to calculate' do
        criteria.payment_date_delta = nil

        expect(subject).to eq(:green)
      end

      it 'is assigned red because because payment pattern delta greater than three' do
        criteria.payment_date_delta = 4

        expect(subject).to eq(:red)
      end

      it 'is assigned red because because payment pattern delta less than negative three' do
        criteria.payment_date_delta = -4

        expect(subject).to eq(:red)
      end

      it 'is assigned red because because payment amount delta that is negative' do
        criteria.payment_amount_delta = 1

        expect(subject).to eq(:red)
      end
    end

    context 'assigning a tenancy to the amber band' do
      it 'happens when balance is greater than £350' do
        criteria.balance = 351

        expect(subject).to eq(:amber)
      end

      it 'happens when debt age is greater than 15 weeks' do
        criteria.days_in_arrears = 16 * 7

        expect(subject).to eq(:amber)
      end

      # FIXME: There's some missing business logic here - nosp can be present and you can be green
      # FIXME: what about when you are amber, have a nosp, make sporadic payments without an agreement
      it 'happens when a valid nosp was served within the last 28 days' do
        criteria.nosp_served = true
        criteria.days_since_last_payment = 7

        expect(subject).to eq(:amber)
      end

      it 'happens when previous agreements have been broken and there are no live agreements' do
        criteria.number_of_broken_agreements = 1

        expect(subject).to eq(:amber)
      end
    end

    context 'assigning a tenancy to the green band' do
      it 'is otherwise green' do
        expect(subject).to eq(:green)
      end
    end
  end
end
