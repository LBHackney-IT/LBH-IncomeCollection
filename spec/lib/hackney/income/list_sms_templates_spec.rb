require 'rails_helper'

describe Hackney::Income::ListSmsTemplates do
  let(:notifications_gateway) { Hackney::Income::StubNotificationsGateway.new(templates: []) }
  let(:tenancy_gateway) { Hackney::Income::StubTenancyGateway.new }
  let(:list_sms_templates) { described_class.new(notifications_gateway: notifications_gateway, tenancy_gateway: tenancy_gateway) }

  subject { list_sms_templates.execute(tenancy_ref: '3456789') }
  alias_method :get_templates, :subject

  it 'should use the notification gateway' do
    expect(notifications_gateway).to receive(:get_text_templates).and_return([])
    get_templates
  end

  context 'when there is one template' do
    let(:notifications_gateway) do
      Hackney::Income::StubNotificationsGateway.new(templates: [
        { id: '1000', name: 'Greeting', body: 'hello ((first name))' }
      ])
    end

    it 'should return the template with pre-filled values' do
      expect(subject).to include(
        an_object_having_attributes(id: '1000', name: 'Greeting', body: 'hello Diana')
      )
    end
  end

  context 'when there is more than one template' do
    let(:notifications_gateway) do
      Hackney::Income::StubNotificationsGateway.new(templates: [
        { id: '1000', name: 'Greeting', body: 'hello Diana' },
        { id: '1001', name: 'Good bye', body: 'goodbye Diana' }
      ])
    end

    it 'should return all the templates with pre-filled values' do
      expect(subject).to include(
        an_object_having_attributes(id: '1000', name: 'Greeting', body: 'hello Diana'),
        an_object_having_attributes(id: '1001', name: 'Good bye', body: 'goodbye Diana')
      )
    end
  end
end
