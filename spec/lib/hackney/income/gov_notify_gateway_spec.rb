require 'rails_helper'

describe Hackney::Income::GovNotifyGateway do
  let(:sms_sender_id) { 'cool_sender_id' }
  # let(:email_reply_to_id) { 'awesome_reply_to_email' }
  let(:api_key) { 'FAKE_API_KEY-53822c9d-b17d-442d-ace7-565d08215d20-53822c9d-b17d-442d-ace7-565d08215d20' }

  subject { described_class.new(sms_sender_id: sms_sender_id, api_key: api_key) }

  context 'when initializing the gateway' do
    it 'should authenticate with Gov Notify' do
      expect(Notifications::Client).to receive(:new).with(api_key)
      subject
    end
  end

  context 'when sending a text message to a live tenant' do
    let(:phone_number) { Faker::PhoneNumber.phone_number }
    before do
      ENV['SEND_LIVE_COMMUNICATIONS'] = 'true'
    end

    it 'should send the message to the live phone number' do
      expect_any_instance_of(Notifications::Client).to receive(:send_sms).with(
        phone_number: phone_number,
        template_id: 'sweet-test-template-id',
        personalisation: {
          'first name' => 'Steven Leighton',
          'balance' => '-£100.00'
        },
        reference: 'amazing-test-reference',
        sms_sender_id: sms_sender_id
      )

      subject.send_text_message(
        phone_number: phone_number,
        template_id: 'sweet-test-template-id',
        variables: {
          'first name' => 'Steven Leighton',
          'balance' => '-£100.00'
        },
        reference: 'amazing-test-reference'
      )
    end

    after do
      ENV.delete('SEND_LIVE_COMMUNICATIONS')
    end
  end

  context 'when sending a text message to a tenant' do
    before do
      ENV['TEST_PHONE_NUMBER'] = '01234 123456'
      ENV['SEND_LIVE_COMMUNICATIONS'] = 'false'
    end

    after do
      ENV.delete('TEST_PHONE_NUMBER')
      ENV.delete('SEND_LIVE_COMMUNICATIONS')
    end

    it 'should send through Gov Notify' do
      expect_any_instance_of(Notifications::Client).to receive(:send_sms).with(
        phone_number: ENV['TEST_PHONE_NUMBER'],
        template_id: 'sweet-test-template-id',
        personalisation: {
          'first name' => 'Steven Leighton',
          'balance' => '-£100.00'
        },
        reference: 'amazing-test-reference',
        sms_sender_id: sms_sender_id
      )

      subject.send_text_message(
        phone_number: 'I am a phone number that will be ignored',
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

  # FIXME: govnotify doesn't appear to currently pass through the reply to email?
  context 'when sending an email to a tenant' do
    before do
      ENV['TEST_EMAIL_ADDRESS'] = 'test@example.com'
      ENV['SEND_LIVE_COMMUNICATIONS'] = 'false'
    end

    after do
      ENV.delete('TEST_EMAIL_ADDRESS')
      ENV.delete('SEND_LIVE_COMMUNICATIONS')
    end

    it 'should send through Gov Notify' do
      expect_any_instance_of(Notifications::Client).to receive(:send_email).with(
        email_address: ENV['TEST_EMAIL_ADDRESS'],
        template_id: 'sweet-test-template-id',
        personalisation: {
          'first name' => 'Steven Leighton'
        },
        reference: 'amazing-test-reference',
        # email_reply_to_id: email_reply_to_id
      )

      subject.send_email(
        recipient: 'I am an email adddress that will be ignored',
        template_id: 'sweet-test-template-id',
        variables: {
          'first name' => 'Steven Leighton'
        },
        reference: 'amazing-test-reference',
        # email_reply_to_id: email_reply_to_id
      )
    end
  end

  context 'when retrieving a list of email templates' do
    let(:template_id) { Faker::IDNumber.valid }

    it 'should return a list of templates' do
      expect_any_instance_of(Notifications::Client).to receive(:get_all_templates)
        .with(type: 'email')
        .and_return(
          Notifications::Client::TemplateCollection.new('templates' => [{
            'id' => template_id,
            'type' => 'email',
            'created_at' => '2016-11-29T11:12:30.12354Z',
            'updated_at' => '2016-11-29T11:12:40.12354Z',
            'created_by' => 'jane.doe@gmail.com',
            'name' => 'template-name',
            'body' => 'hello ((first name)), how are you?',
            'subject' => 'email subject',
            'version' => '2'
          }])
        )

      expect(subject.get_email_templates).to eq([{
        id: template_id,
        name: 'template-name',
        subject: 'email subject',
        body: 'hello ((first name)), how are you?'
      }])
    end
  end
end
