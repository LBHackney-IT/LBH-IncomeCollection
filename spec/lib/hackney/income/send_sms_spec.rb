require 'rails_helper'

describe Hackney::Income::SendSms do
  let(:tenancy) do
    Hackney::Tenancy.new.tap do |t|
      t.ref = '012345/01'
      t.primary_contact = {
        first_name: 'Diana',
        contact_number: '01234 123456'
      }
    end
  end

  let(:template_id) { 'this-is-a-template-id' }
  let(:notification_gateway) { StubNotificationGateway.new }
  let(:send_sms) { described_class.new(notification_gateway: notification_gateway) }

  context 'when sending an SMS manually' do
    subject do
      send_sms.execute(tenancy: tenancy, template_id: template_id)
      notification_gateway.last_text_message
    end

    it 'should map the tenancy to a set of variables' do
      expect(subject).to include(
        variables: {
          'first name' => 'Diana'
        }
      )
    end

    it 'should pass through the phone number' do
      expect(subject).to include(
        phone_number: '01234 123456'
      )
    end

    it 'should pass through the template id' do
      expect(subject).to include(
        template_id: template_id
      )
    end

    it 'should generate a tenant and message representative reference' do
      expect(subject).to include(
        reference: 'manual_012345/01'
      )
    end
  end
end

class StubNotificationGateway
  attr_reader :last_text_message

  def initialize
    @last_text_message = nil
  end

  def send_text_message(phone_number:, template_id:, reference:, variables:)
    @last_text_message = {
      phone_number: phone_number,
      template_id: template_id,
      reference: reference,
      variables: variables
    }
  end
end
