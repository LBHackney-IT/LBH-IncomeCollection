require 'rails_helper'

describe Hackney::Income::SendSms do
  let(:tenancy_gateway) { Hackney::Income::StubTenancyGateway.new }
  let(:notification_gateway) { Hackney::Income::StubNotificationsGateway.new }
  let(:events_gateway) { Hackney::Income::StubEventsGateway.new }
  let(:events) { events_gateway.events_for(tenancy_ref: '2345678') }

  let(:send_sms) do
    described_class.new(
      tenancy_gateway: tenancy_gateway,
      notification_gateway: notification_gateway,
      events_gateway: events_gateway
    )
  end

  context 'when sending an SMS manually' do
    subject do
      send_sms.execute(tenancy_ref: '2345678', template_id: 'this-is-a-template-id')
      notification_gateway.last_text_message
    end

    alias_method :send_sms_message, :subject

    it 'should map the tenancy to a set of variables' do
      expect(subject).to include(
        variables: {
          'first name' => 'Bruce'
        }
      )
    end

    it 'should pass through the phone number' do
      expect(subject).to include(
        phone_number: '0208 123 1234'
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

    it 'should create a tenancy event' do
      send_sms_message
      expect(events).to include(
        tenancy_ref: '2345678',
        type: 'sms_message_sent',
        description: 'Sent SMS message to 0208 123 1234',
        automated: false
      )
    end
  end
end
