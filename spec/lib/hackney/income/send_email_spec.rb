require 'rails_helper'

describe Hackney::Income::SendEmail do
  let(:tenancy_gateway) { Hackney::Income::StubTenancyGatewayBuilder.build_stub.new }
  let(:notification_gateway) { Hackney::Income::StubNotificationsGateway.new }
  let(:send_email) { described_class.new(tenancy_gateway: tenancy_gateway, notification_gateway: notification_gateway) }

  context 'when sending an email manually' do
    subject do
      send_email.execute(tenancy_ref: '2345678', template_id: 'this-is-a-template-id', email_addresses: ['test@example.com'])
      notification_gateway.last_email
    end

    it 'should map the tenancy to a set of variables' do
      expect(subject).to include(
        variables: include(
          'formal name' => 'Mr Wayne'
        )
      )
    end

    it 'should pass through email address from the primary contact' do
      expect(subject).to include(
        recipient: 'test@example.com'
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
