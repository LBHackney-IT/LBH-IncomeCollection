require 'rails_helper'

describe Hackney::Income::GovNotifyGateway do
  let(:sms_sender_id) { 'cool_sender_id' }
  # let(:email_reply_to_id) { 'awesome_reply_to_email' }
  let(:api_key) { 'FAKE_API_KEY-53822c9d-b17d-442d-ace7-565d08215d20-53822c9d-b17d-442d-ace7-565d08215d20' }
  let(:api_host) { 'https://example.com/api/' }

  subject { described_class.new(sms_sender_id: sms_sender_id, api_key: api_key, api_host: api_host) }

  context 'when sending a text message to a live tenant' do
    let(:tenancy_ref) { "#{Faker::Number.number(8)}/#{Faker::Number.number(2)}" }
    let(:phone_number) { Faker::PhoneNumber.phone_number }
    let(:template_id) { Faker::LeagueOfLegends.location }
    let(:first_name) { Faker::LeagueOfLegends.champion }
    let(:balance) { "-#{Faker::Number.number(3)}" }
    let(:reference) { Faker::LeagueOfLegends.summoner_spell }
    let(:username) { Faker::Name.name }

    before do
      stub_request(:post, "#{api_host}v1/messages/send_sms")
        .with(
          body: {
            tenancy_ref: tenancy_ref,
            phone_number: phone_number,
            template_id: template_id,
            variables: {
              'first name' => first_name,
              balance: balance
            },
            reference: reference,
            sms_sender_id: sms_sender_id,
            username: username
          }.to_json
        ).to_return(status: 200, body: '', headers: {})
    end

    it 'should send the message to the live phone number' do
      subject.send_text_message(
        tenancy_ref: tenancy_ref,
        phone_number: phone_number,
        template_id: template_id,
        variables: {
          'first name' => first_name,
          :balance => balance
        },
        reference: reference,
        username: username
      )

      expect have_requested(:post, "#{api_host}v1/messages/send_sms")
        .with(
          body: {
            tenancy_ref: tenancy_ref,
            phone_number: phone_number,
            template_id: template_id,
            variables: {
              'first name' => first_name,
              :balance => balance
            },
            reference: reference,
            username: username,
            sms_sender_id: sms_sender_id
          }.to_json
        ).once
    end
  end

  context 'when retrieving a list of text message templates' do
    let(:template_id) { Faker::IDNumber.valid }
    let(:name) { Faker::LeagueOfLegends.location }
    let(:body) { Faker::LeagueOfLegends.quote }
    let(:username) { Faker::Number.number(3) }

    before do
      stub_request(:get, "#{api_host}v1/messages/get_templates?type=sms")
        .to_return(
          status: 200,
          body: [{
                   id: template_id,
                   name: name,
                   body: body
                 }].to_json
        )
    end

    it 'should return a list of templates' do
      expect(subject.get_text_templates).to eq([{
        id: template_id,
        name: name,
        body: body
      }])
    end
  end

  # FIXME: govnotify doesn't appear to currently pass through the reply to email?
  context 'when sending an email to a tenant' do
    let(:email) { Faker::Internet.email }
    let(:template_id) { Faker::LeagueOfLegends.location }
    let(:first_name) { Faker::LeagueOfLegends.champion }
    let(:reference) { Faker::LeagueOfLegends.summoner_spell }
    let(:tenancy_ref) { "#{Faker::Number.number(8)}/#{Faker::Number.number(2)}" }
    let(:username) { Faker::Name.name }

    before do
      stub_request(:post, "#{api_host}v1/messages/send_email")
        .with(
          body: {
            tenancy_ref: tenancy_ref,
            email_address: email,
            template_id: template_id,
            variables: {
              'first name' => first_name
            },
            reference: reference,
            username: username
          }.to_json
        ).to_return(status: 200, body: '', headers: {})
    end

    it 'should send through Gov Notify' do
      subject.send_email(
        tenancy_ref: tenancy_ref,
        recipient: email,
        template_id: template_id,
        variables: {
          'first name' => first_name
        },
        reference: reference,
        username: username
        # email_reply_to_id: email_reply_to_id
      )
    end
  end

  context 'when retrieving a list of email templates' do
    let(:template_id) { Faker::IDNumber.valid }
    let(:name) { Faker::LeagueOfLegends.location }
    let(:email_subject) { Faker::LeagueOfLegends.masteries }
    let(:body) { Faker::LeagueOfLegends.quote }

    before do
      stub_request(:get, "#{api_host}v1/messages/get_templates?type=email")
        .to_return(
          status: 200,
          body: [{
                   id: template_id,
                   name: name,
                   subject: email_subject,
                   body: body
                 }].to_json,
          headers: {}
        )
    end

    it 'should return a list of templates' do
      expect(subject.get_email_templates).to eq([{
        id: template_id,
        name: name,
        subject: email_subject,
        body: body
      }])
    end
  end

  context 'when failing to get email templates' do
    before do
      stub_request(:get, "#{api_host}v1/messages/get_templates?type=email")
        .to_return(status: 500)
    end

    it 'should throw an error' do
      expect { subject.get_email_templates }.to raise_error(
        Exceptions::IncomeApiError,
        "[Income API error: Received 500 response] when trying to get_email_templates 'https://example.com/api/v1/messages/get_templates?type=email'"
      )
    end
  end

  context 'when failing to get sms templates' do
    before do
      stub_request(:get, "#{api_host}v1/messages/get_templates?type=sms")
        .to_return(status: 500)
    end

    it 'should throw an error' do
      expect { subject.get_text_templates }.to raise_error(
        Exceptions::IncomeApiError,
        "[Income API error: Received 500 response] when trying to get_text_templates 'https://example.com/api/v1/messages/get_templates?type=sms'"
      )
    end
  end
end
