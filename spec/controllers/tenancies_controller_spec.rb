require 'rails_helper'

describe TenanciesController do
  context '#index' do
    it 'should assign a list of valid tenancies' do
      get :index

      expect(assigns(:tenancies_in_arrears)).to all(be_instance_of(Hackney::TenancyListItem))
      expect(assigns(:tenancies_in_arrears)).to all(be_valid)
    end
  end

  context '#show' do
    it 'should assign a valid tenancy' do
      get :show, { params: { id: '1234567' } }

      expect(assigns(:tenancy)).to be_instance_of(Hackney::Tenancy)
      expect(assigns(:tenancy)).to be_valid
    end
  end
end