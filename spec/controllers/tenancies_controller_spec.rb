require 'rails_helper'

describe TenanciesController do
  before do
    stub_const('Hackney::Income::LessDangerousTenancyGateway', Hackney::Income::StubTenancyGatewayBuilder.build_stub)
    stub_const('Hackney::Income::SqlTenancyCaseGateway', Hackney::Income::StubTenancyCaseGatewayBuilder.build_stub)
    stub_const('Hackney::Income::TransactionsGateway', Hackney::Income::StubTransactionsGateway)
    stub_const('Hackney::Income::SchedulerGateway', Hackney::Income::StubSchedulerGateway)
    stub_authentication
  end

  context '#index' do
    it 'should assign a list of valid tenancies' do
      get :index

      expect(assigns(:user_assigned_tenancies)).to all(be_instance_of(Hackney::Income::Domain::TenancyListItem))
      expect(assigns(:user_assigned_tenancies)).to all(be_valid)
    end
  end

  context '#show' do
    it 'should assign a valid tenancy' do
      get :show, params: { id: '1234567' }

      expect(assigns(:tenancy)).to be_present
      expect(assigns(:tenancy)).to be_instance_of(Hackney::Income::Domain::Tenancy)
      expect(assigns(:tenancy)).to be_valid
    end
  end
end
