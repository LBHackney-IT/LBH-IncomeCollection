require 'rails_helper'

describe ActionDiaryEntryController, type: :controller do
  let(:tenancy_ref) { Faker::Lorem.characters(8) }
  let(:user_id) { stub_user['id'] }

  let(:create_action_diary_entry_class_stub) { class_double(Hackney::Income::CreateActionDiaryEntry) }
  let(:create_action_diary_entry) { instance_double(Hackney::Income::CreateActionDiaryEntry) }

  before do
    stub_authentication

    stub_const('Hackney::Income::CreateActionDiaryEntry', create_action_diary_entry_class_stub)
    allow(create_action_diary_entry_class_stub).to receive(:new).and_return(create_action_diary_entry).once

    stub_const('Hackney::Income::TenancyGateway', Hackney::Income::StubTenancyGatewayBuilder.build_stub)
  end

  context 'creating an action diary entry successfully' do
    it 'should call the create action diary entry use case correctly' do
      assert_generates "/tenancies/#{tenancy_ref}/action_diary", controller: 'action_diary_entry', action: 'create', tenancy_ref: tenancy_ref
    end

    it 'should call the create action diary entry use case correctly' do
      expect(create_action_diary_entry).to receive(:execute).with(
        tenancy_ref: tenancy_ref,
        action_code: 'DEB',
        comment: 'Test comment',
        user_id: user_id
      )

      post :create, params: {
        tenancy_ref: tenancy_ref,
        balance: 100.12,
        code: 'DEB',
        comment: 'Test comment'
      }
    end

    it 'should call redirect me to the tenancy page' do
      expect(create_action_diary_entry).to receive(:execute)
      post :create, params: {
        tenancy_ref: tenancy_ref,
        balance: 100.12,
        code: 'DEB',
        comment: 'Test comment'
      }

      expect(response).to redirect_to(tenancy_path(id: tenancy_ref))
    end

    it 'raises an exception when a invalid code is used' do
      post :create, params: {
        tenancy_ref: tenancy_ref,
        balance: 100.12,
        code: 'Wibble',
        comment: 'ah Wibble'
      }

      expect(response.status).to eq 400
    end

    it 'should show me a success message' do
      expect(create_action_diary_entry).to receive(:execute)
      post :create, params: {
        tenancy_ref: tenancy_ref,
        balance: 100.12,
        code: 'DEB',
        comment: 'Test comment'
      }

      expect(flash[:notice]).to eq('Successfully created an action diary entry')
    end
  end

  context 'listing all actions for a tenancy' do
    it 'should be accessible' do
      assert_generates "/tenancies/#{tenancy_ref}/action_diary", controller: 'action_diary_entry', action: 'index', tenancy_ref: tenancy_ref
    end

    it 'should call the view actions use case correctly' do
      expect_any_instance_of(Hackney::Income::ViewActions).to receive(:execute).with(
        tenancy_ref: tenancy_ref
      )

      get :index, params: { tenancy_ref: tenancy_ref }
    end
  end

  context 'returning action diary form' do
    it 'should be accessible' do
      assert_generates "/tenancies/#{tenancy_ref}/action_diary/new", controller: 'action_diary_entry', action: 'show', tenancy_ref: tenancy_ref
    end

    before do
      stub_const('Hackney::Income::TenancyGateway', Hackney::Income::StubTenancyGatewayBuilder.build_stub(with_tenancies:  [{
        first_name: 'Clark',
        last_name: 'Kent',
        title: 'Mr',
        address_1: '1 Fortress of Solitude',
        tenancy_ref: tenancy_ref,
        assigned_user_id: 123
      }]))
    end

    it 'should call the view actions use case correctly' do
      # needs checks,

      get :show, params: { tenancy_ref: tenancy_ref }

      expect(assigns(:tenancy)).to be_an_instance_of(Hackney::Income::Domain::Tenancy)
      expect(assigns(:code_options)).not_to be_nil
    end
  end
end
