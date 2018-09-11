require 'rails_helper'

describe Hackney::Income::ListTenanciesInArrears do
  context 'when listing all tenancies in arrears' do
    let!(:tenancy_gateway) do
      Hackney::Income::StubTenancyGatewayBuilder.build_stub.new
    end

    let!(:list_tenancies_in_arrears_use_case) do
      described_class.new(tenancy_gateway: tenancy_gateway)
    end

    subject do
      list_tenancies_in_arrears_use_case.execute
    end

    it 'should include a name and tenancy ref for each tenancy' do
      expect(subject.first.ref).to eq('1234567')
      expect(subject.first.current_balance).to eq(1200.99)
      expect(subject.first.current_arrears_agreement_status).to eq('100')
      expect(subject.first.latest_action_code).to eq('Z00')
      expect(subject.first.latest_action_date).to eq('2018-05-01 00:00:00')
      expect(subject.first.primary_contact_name).to eq('Mr Clark Kent')
      expect(subject.first.primary_contact_short_address).to eq('1 Fortress of Solitude')
      expect(subject.first.primary_contact_postcode).to eq('E1 123')
    end
  end
end
