require 'rails_helper'

describe ActionDiaryEntryController do
  let(:tenancy_ref) { Faker::Lorem.characters(8) }

  before do
    stub_authentication
    stub_const('Hackney::Income::LessDangerousTenancyGateway', Hackney::Income::StubTenancyGatewayBuilder.build_stub)
    stub_const('Hackney::Income::CreateActionDiaryEntry', Hackney::Income::StubCreateActionDiaryEntry)
  end

  context 'creating an action diary entry successfully' do
    it 'should call the create action diary entry use case correctly' do
      expect_any_instance_of(Hackney::Income::CreateActionDiaryEntry).to receive(:execute).with(
        tenancy_ref: '3456789',
        balance: '100.12',
        code: 'GEN',
        type: '',
        date: Date.today.strftime('%YYYY-%MM-%DD'),
        comment: 'Test comment',
        universal_housing_username: 'RFoster'
      )

      post :create, params: {
        id: '3456789',
        tenancy_ref: '3456789',
        balance: 100.12,
        code: 'GEN',
        type: '',
        comment: 'Test comment',
        universal_housing_username: 'RFoster'
      }
    end

    it 'should call redirect me to the tenancy page' do
      post :create, params: {
        id: '3456789',
        tenancy_ref: '3456789',
        balance: 100.12,
        code: 'GEN',
        type: '',
        date: Date.today,
        comment: 'Test comment',
        universal_housing_username: 'RFoster'
      }

      expect(response).to redirect_to(tenancy_path(id: '3456789'))
    end

    it 'should show me a success message' do
      post :create, params: {
        id: '3456789',
        tenancy_ref: '3456789',
        balance: 100.12,
        code: 'GEN',
        type: '',
        date: Date.today,
        comment: 'Test comment',
        universal_housing_username: 'RFoster'
      }

      expect(flash[:notice]).to eq('Successfully created an action diary entry')
    end
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
