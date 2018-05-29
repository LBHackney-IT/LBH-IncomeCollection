require 'rails_helper'

describe Hackney::Income::GovNotifyGateway do
  let(:sms_sender_id) { 'cool_sender_id' }
  let(:api_key) { 'FAKE_API_KEY-53822c9d-b17d-442d-ace7-565d08215d20-53822c9d-b17d-442d-ace7-565d08215d20' }

  subject { described_class.new(sms_sender_id: sms_sender_id, api_key: api_key) }

  context 'when initializing the gateway' do
    it 'should authenticate with Gov Notify' do
      expect(Notifications::Client).to receive(:new).with(api_key)
      subject
    end
  end

  context 'when sending a text message to a tenant' do
    it 'should send through Gov Notify' do
      expect_any_instance_of(Notifications::Client).to receive(:send_sms).with(
        phone_number: '01234 123456',
        template_id: 'sweet-test-template-id',
        personalisation: {
          'first name' => 'Steven Leighton',
          'balance' => '-£100.00'
        },
        reference: 'amazing-test-reference',
        sms_sender_id: sms_sender_id
      )

      subject.send_text_message(
        phone_number: '01234 123456',
        template_id: 'sweet-test-template-id',
        variables: {
          'first name' => 'Steven Leighton',
          'balance' => '-£100.00'
        },
        reference: 'amazing-test-reference'
      )
    end
  end

  context 'when retrieving a list of text message templates' do
    let(:template_id) { Faker::IDNumber.valid }

    it 'should return a list of templates' do
      expect_any_instance_of(Notifications::Client).to receive(:get_all_templates)
        .with(type: 'sms')
        .and_return(
          Notifications::Client::TemplateCollection.new('templates' => [{
            'id' => template_id,
            'type' => 'sms',
            'created_at' => '2016-11-29T11:12:30.12354Z',
            'updated_at' => '2016-11-29T11:12:40.12354Z',
            'created_by' => 'jane.doe@gmail.com',
            'name' => 'template-name',
            'body' => 'hello ((first name)), how are you?',
            'version' => '2'
          }])
        )

      expect(subject.get_text_templates).to eq([{
        id: template_id,
        name: 'template-name',
        body: 'hello ((first name)), how are you?'
      }])
    end
  end
end