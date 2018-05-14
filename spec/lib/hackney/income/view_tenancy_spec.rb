require 'rails_helper'
require 'date'

describe Hackney::Income::ViewTenancy do
  context 'when viewing a tenancy' do
    let!(:tenancy_gateway) do
      Hackney::Income::StubTenancyGateway.new
    end

    let!(:view_tenancy_use_case) do
      described_class.new(tenancy_gateway: tenancy_gateway)
    end

    subject do
      view_tenancy_use_case.execute(tenancy_ref: tenancy_ref)
    end

    context 'with a tenancy_ref of 3456789' do
      let!(:tenancy_ref) { '3456789' }

      it 'should contain basic details about the tenancy' do
        expect(subject.ref).to eq('3456789')
        expect(subject.current_balance).to eq('-1200.99')
        expect(subject.type).to eq('Temporary Accommodation')
        expect(subject.start_date).to eq(Date.new(2018, 1, 1))
      end

      it 'should include contact details' do
        expect(subject.primary_contact).to eq(
          first_name: 'Diana',
          last_name: 'Prince',
          title: 'Ms',
          contact_number: '0208 123 1234',
          email_address: 'test@example.com'
        )
      end

      it 'should contain the address of the tenancy' do
        expect(subject.address).to eq(
          address_1: '1 Themyscira',
          address_2: 'Hackney',
          address_3: 'London',
          address_4: 'UK',
          post_code: 'E1 123'
        )
      end

      it 'should contain transactions related to the tenancy' do
        expect(subject.transactions).to include(
          type: 'payment',
          payment_method: 'Direct Debit',
          amount: '12.99',
          date: Date.new(2018, 1, 1),
          final_balance: '100.00'
        )
      end

      it 'should contain agreements related to the tenancy' do
        expect(subject.agreements).to include(
          status: 'active',
          type: 'court_ordered',
          value: '10.99',
          frequency: 'weekly',
          created_date: Date.new(2017, 11, 1)
        )
      end

      it 'should contain arrears actions against the tenancy' do
        expect(subject.arrears_actions).to include(
          type: 'general_note',
          automated: false,
          user: {
            name: 'Brainiac'
          },
          date: Date.new(2018, 1, 1),
          description: 'this tenant is in arrears!!!'
        )
      end
    end
  end
end
