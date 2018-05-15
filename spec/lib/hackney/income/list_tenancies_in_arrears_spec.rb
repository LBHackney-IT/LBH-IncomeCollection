require 'rails_helper'

describe Hackney::Income::ListTenanciesInArrears do
  context 'when listing all tenancies in arrears' do
    let!(:tenancy_gateway) do
      Hackney::Income::StubTenancyGateway.new
    end

    let!(:list_tenancies_in_arrears_use_case) do
      described_class.new(tenancy_gateway: tenancy_gateway)
    end

    subject do
      list_tenancies_in_arrears_use_case.execute
    end

    it 'should include a name and tenancy ref for each tenancy' do
      expect(subject.first.address_1).to eq('1 Fortress of Solitude')
      expect(subject.first.post_code).to eq('E1 123')
      expect(subject.first.current_balance).to eq('-1200.99')
      expect(subject.first.tenancy_ref).to eq('1234567')
      expect(subject.first.primary_contact).to eq(
        first_name: 'Clark',
        last_name: 'Kent',
        title: 'Mr'
      )
    end
  end
end
