require 'rails_helper'

describe TenanciesArrearsActionsController do
  let(:tenancy_ref) { Faker::Lorem.characters(8) }

  before do
    stub_authentication
  end

  context 'listing all actions for a tenancy' do
    it 'should call the view actions use case correctly' do
      expect_any_instance_of(Hackney::Income::ViewActions).to receive(:execute).with(
        tenancy_ref: tenancy_ref
      )

      get :index, params: { id: tenancy_ref }
    end
  end
end
