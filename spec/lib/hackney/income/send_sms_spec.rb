require 'rails_helper'

describe Hackney::Income::SendSms do
  let(:tenancy_gateway) { Hackney::Income::StubTenancyGatewayBuilder.build_stub.new }
  let(:notification_gateway) { Hackney::Income::StubNotificationsGateway.new }
  let!(:phone_number) { Faker::PhoneNumber.phone_number }

  let(:send_sms) do
    described_class.new(
      tenancy_gateway: tenancy_gateway,
      notification_gateway: notification_gateway
    )
  end

  context 'when sending an SMS manually' do
    subject do
      send_sms.execute(tenancy_ref: '2345678', username: Faker::Name.name, template_id: 'this-is-a-template-id', phone_numbers: [phone_number])
      notification_gateway.last_text_message
    end

    alias_method :send_sms_message, :subject

    it 'should map the tenancy to a set of variables' do
      expect(subject).to include(
        variables: include(
          'formal name' => 'Mr Wayne'
        )
      )
    end

    it 'should pass through the phone number' do
      expect(subject).to include(
        phone_number: phone_number
      )
    end

    it 'should pass through the template id' do
      expect(subject).to include(
        template_id: 'this-is-a-template-id'
      )
    end

    it 'should generate a tenant and message representative reference' do
      expect(subject).to include(
        reference: 'manual_2345678'
      )
    end
  end
end
