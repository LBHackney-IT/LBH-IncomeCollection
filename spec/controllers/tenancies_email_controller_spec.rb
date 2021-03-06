require 'rails_helper'

describe TenanciesEmailController do
  before do
    sign_in
    stub_const('Hackney::Income::TenancyGateway', Hackney::Income::StubTenancyGatewayBuilder.build_stub)
    stub_const('Hackney::Income::GovNotifyGateway', Hackney::Income::StubNotificationsGateway)
    stub_const('Hackney::Income::TransactionsGateway', Hackney::Income::StubTransactionsGateway)
    stub_const('Hackney::Income::GetActionDiaryEntriesGateway', Hackney::Income::StubGetActionDiaryEntriesGateway)
  end

  context '#show' do
    it 'displays available templates' do
      get :show, params: { id: '3456789' }

      expect(assigns(:email_templates)).to_not be_empty
      expect(assigns(:email_templates)).to all(be_instance_of(Hackney::EmailTemplate))
      expect(assigns(:email_templates)).to all(be_valid)
    end

    it 'displays basic tenant details' do
      get :show, params: { id: '3456789' }

      expect(assigns(:tenancy)).to be_present
      expect(assigns(:tenancy)).to be_instance_of(Hackney::Income::Domain::Tenancy)
      expect(assigns(:tenancy)).to be_valid
    end
  end

  context 'sending an email successfully' do
    let(:username) { @user.name }

    it 'should call the send email use case correctly' do
      expect_any_instance_of(Hackney::Income::SendEmail).to receive(:execute).with(
        tenancy_ref: '3456789',
        email_addresses: ['test@example.com'],
        template_id: '00003',
        username: username
      )

      post :create, params: {
        id: '3456789',
        template_id: '00003',
        email_addresses: ['test@example.com']
      }
    end

    it 'should call redirect me to the tenancy page' do
      post :create, params: {
        id: '3456789',
        template_id: '00003',
        username: username,
        email_addresses: ['test@example.com']
      }
      expect(response).to redirect_to(tenancy_path(id: '3456789'))
    end

    it 'should show me a success message' do
      post :create, params: {
        id: '3456789',
        template_id: '00003',
        username: username,
        email_addresses: ['test@example.com']
      }
      expect(flash[:notice]).to eq('Successfully sent the tenant an Email')
    end
  end
end
