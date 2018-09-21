require 'rails_helper'

describe TenanciesTransactionsController do
  before { stub_authentication }

  context '#index' do
    let(:tenancy_ref) { Faker::IDNumber.valid }
    let(:dummy) { double }

    it 'should call the ViewTenancy use case' do
      expect_any_instance_of(Hackney::Income::ViewTenancy).to receive(:execute).with(tenancy_ref: tenancy_ref)

      get :index, params: { id: tenancy_ref }
    end

    it 'should assign the ViewTenancy response to @tenancy' do
      allow_any_instance_of(Hackney::Income::ViewTenancy).to receive(:execute).with(tenancy_ref: tenancy_ref).and_return(dummy)

      get :index, params: { id: tenancy_ref }

      expect(assigns(:tenancy)).to be(dummy)
    end
  end
end
