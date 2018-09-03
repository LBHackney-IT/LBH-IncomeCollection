require 'rails_helper'

describe ActionDiaryEntryController do
  before do
    stub_authentication
    stub_const('Hackney::Income::LessDangerousTenancyGateway', Hackney::Income::StubTenancyGatewayBuilder.build_stub)
    stub_const('Hackney::Income::CreateActionDiaryEntry', Hackney::Income::StubCreateActionDiaryEntry)
    # stub_const('Hackney::Income::GovNotifyGateway', Hackney::Income::StubNotificationsGateway)
    # stub_const('Hackney::Income::TransactionsGateway', Hackney::Income::StubTransactionsGateway)
    # stub_const('Hackney::Income::SqlEventsGateway', Hackney::Income::StubEventsGateway)
    # stub_const('Hackney::Income::SchedulerGateway', Hackney::Income::StubSchedulerGateway)
  end
  #
  # context '#show' do
  #   it 'should render a form for creating action diary entries' do
  #     get :show, params: { id: '3456789' }
  #
  #     expect(subject).to render_template(:show)
  #   end
  #
  #   # it 'displays basic tenant details' do
  #   #   get :show, params: { id: '3456789' }
  #   #
  #   #   expect(assigns(:tenancy)).to be_present
  #   #   expect(assigns(:tenancy)).to be_instance_of(Hackney::Income::Domain::Tenancy)
  #   #   expect(assigns(:tenancy)).to be_valid
  #   # end
  # end

  context 'creating an action diary entry successfully' do
    it 'should call the send sms use case correctly' do
      expect_any_instance_of(Hackney::Income::CreateActionDiaryEntry).to receive(:execute).with(
        tenancy_ref: '3456789',
        balance: 100.12,
        code: 'GEN',
        type: 'General Note',
        date: Date.today,
        comment: 'Test comment',
        universal_housing_username: 'RFoster',
      )

      post :create, params: {
        id: '3456789',
        tenancy_ref: '3456789',
        balance: 100.12,
        code: 'GEN',
        type: 'General Note',
        date: Date.today,
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
        type: 'General Note',
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
        type: 'General Note',
        date: Date.today,
        comment: 'Test comment',
        universal_housing_username: 'RFoster'
      }

      expect(flash[:notice]).to eq('Successfully created an action diary entry')
    end
  end
end
