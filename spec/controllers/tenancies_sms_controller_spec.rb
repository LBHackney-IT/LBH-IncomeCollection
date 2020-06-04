require 'rails_helper'

describe TenanciesSmsController do
  let(:phone_number) { Faker::PhoneNumber.phone_number }

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
    let(:username) { @user.name }

    it 'should call the send sms use case correctly' do
      expect_any_instance_of(Hackney::Income::SendSms).to receive(:execute).with(
        tenancy_ref: '3456789',
        template_id: '00001',
        username: username,
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

  context 'sending an sms unsuccessfully' do
    let(:document_response) { Net::HTTPResponse.new(1.1, 400, 'NOT OK') }

    it 'should show an error message' do
      expect_any_instance_of(Hackney::Income::GovNotifyGateway)
          .to receive(:send_text_message)
                  .and_raise(
                    Exceptions::IncomeApiError::UnprocessableEntity.new(Net::HTTPResponse.new(1.1, 400, 'NOT OK')), "Failed to send sms: Invalid phone number provided: #{phone_number}"
                  )

      post :create, params: { id: '3456789', template_id: '00001', phone_numbers: [phone_number] }

      expect(response).to redirect_to(create_tenancy_sms_path(id: '3456789'))

      expect(flash[:notice]).to eq("Failed to send sms: Invalid phone number provided: #{phone_number}")
    end
  end
end
