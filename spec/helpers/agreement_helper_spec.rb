require 'rails_helper'

describe AgreementHelper do
  describe '#show_end_date' do
    let(:params) do
      {
        total_arrears: nil,
        start_date: nil,
        frequency: nil,
        amount: nil
      }
    end
    it 'should return nil if params are missing' do
      expect(helper.show_end_date(params)).to eq(nil)
    end

    context 'weekly installments' do
      let(:params) do
        {
          total_arrears: '20',
          start_date: '2020-12-01',
          frequency: 'weekly',
          amount: '20'
        }
      end
      it 'calculates the end date for a single instalment' do
        expected_end_date = 'December 1st, 2020'
        expect(helper.show_end_date(params)).to eq(expected_end_date)
      end

      it 'calculates end date when its exactly 2 weeks to complete' do
        params[:total_arrears] = 40
        expected_end_date = 'December 8th, 2020'
        expect(helper.show_end_date(params)).to eq(expected_end_date)
      end

      it 'calculates end date when the last payment is less than the agreed amount' do
        params[:total_arrears] = 50
        expected_end_date = 'December 15th, 2020'
        expect(helper.show_end_date(params)).to eq(expected_end_date)
      end
    end

    context 'monthly installments' do
      let(:params) do
        {
          total_arrears: '40',
          start_date: '2020-12-01',
          frequency: 'monthly',
          amount: '20'
        }
      end
      it 'calculates the end date for 2 instalments' do
        expected_end_date = 'January 1st, 2021'
        expect(helper.show_end_date(params)).to eq(expected_end_date)
      end
    end

    context 'fortnightly installments' do
      let(:params) do
        {
          total_arrears: '40',
          start_date: '2020-12-01',
          frequency: 'fortnightly',
          amount: '20'
        }
      end
      it 'calculates the end date for 2 instalments' do
        expected_end_date = 'December 15th, 2020'
        expect(helper.show_end_date(params)).to eq(expected_end_date)
      end
    end

    context '4 weekly installments' do
      let(:params) do
        {
          total_arrears: '50',
          start_date: '2020-12-01',
          frequency: '4 weekly',
          amount: '20'
        }
      end
      it 'calculates the end date for 3 instalments' do
        expected_end_date = 'January 26th, 2021'
        expect(helper.show_end_date(params)).to eq(expected_end_date)
      end
    end

    context 'when there is an initial payment amount before or on the date of first instalment' do
      let(:params) do
        {
          total_arrears: '50',
          start_date: '2020-12-01',
          frequency: 'weekly',
          amount: '20',
          initial_payment_amount: '30'
        }
      end
      it 'calculates the end date for a single instalment' do
        expected_end_date = 'December 1st, 2020'
        expect(helper.show_end_date(params)).to eq(expected_end_date)
      end

      it 'calculates end date when its exactly 2 instalments to complete' do
        params[:total_arrears] = 70
        expected_end_date = 'December 8th, 2020'
        expect(helper.show_end_date(params)).to eq(expected_end_date)
      end

      it 'calculates end date when the last payment is less than the agreed amount' do
        params[:total_arrears] = 80
        expected_end_date = 'December 15th, 2020'
        expect(helper.show_end_date(params)).to eq(expected_end_date)
      end
    end
  end
end
