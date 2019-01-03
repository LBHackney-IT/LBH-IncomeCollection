require 'rails_helper'

describe TenanciesSmsController do
  let(:phone_number) { Faker::PhoneNumber.phone_number }

  before do
    stub_authentication
    stub_const('Hackney::Income::TenancyGateway', Hackney::Income::StubTenancyGatewayBuilder.build_stub)
    stub_const('Hackney::Income::GovNotifyGateway', Hackney::Income::StubNotificationsGateway)
    stub_const('Hackney::Income::TransactionsGateway', Hackney::Income::StubTransactionsGateway)
  end

  context '#show' do
    it 'displays available templates' do
      get :show, params: { id: '3456789' }

      expect(assigns(:sms_templates)).to_not be_empty
      expect(assigns(:sms_templates)).to all(be_instance_of(Hackney::SmsTemplate))
      expect(assigns(:sms_templates)).to all(be_valid)
    end

    it 'displays basic tenant details' do
      get :show, params: { id: '3456789' }

      expect(assigns(:tenancy)).to be_present
      expect(assigns(:tenancy)).to be_instance_of(Hackney::Income::Domain::Tenancy)
      expect(assigns(:tenancy)).to be_valid
    end
  end

  context 'sending an sms successfully' do
    it 'should call the send sms use case correctly' do
      expect_any_instance_of(Hackney::Income::SendSms).to receive(:execute).with(
        tenancy_ref: '3456789',
        template_id: '00001',
        user_id: 123,
        phone_numbers: [phone_number]
      )

      post :create, params: { id: '3456789', template_id: '00001', phone_numbers: [phone_number] }
    end

    it 'should call redirect me to the tenancy page' do
      post :create, params: { id: '3456789', template_id: '00001', phone_numbers: [phone_number] }
      expect(response).to redirect_to(tenancy_path(id: '3456789'))
    end

    it 'should show me a success message' do
      post :create, params: { id: '3456789', template_id: '00001', phone_numbers: [phone_number] }
      expect(flash[:notice]).to eq('Successfully sent the tenant an SMS message')
    end
  end
end
