require 'rails_helper'

describe Hackney::Income::LettersGateway do
  let(:api_key) { 'FAKE_API_KEY-53822c9d-b17d-442d-ace7-565d08215d20-53822c9d-b17d-442d-ace7-565d08215d20' }
  let(:api_host) { 'https://example.com/api/' }
  let(:template_id) { Faker::Games::LeagueOfLegends.location }
  let(:user) do
    Hackney::Income::Domain::User.new.tap do |u|
      u.id = Faker::Number.number(digits: 3)
      u.name = Faker::Name.name
      u.email = Faker::Internet.email
      u.groups = []
    end
  end
  let(:payment_ref) { Faker::Number.number(digits: 8) }
  let(:tenancy_ref) { Faker::Number.number(digits: 6) }
  let(:uuid) { SecureRandom.uuid }
  let(:id) { Faker::Number.number(digits: 2) }

  subject { described_class.new(api_key: api_key, api_host: api_host) }

  context 'when successfully retrieving letter preview' do
    before do
      stub_request(:post, "#{api_host}v1/messages/letters")
        .with(
          body: {
            payment_ref: payment_ref,
            tenancy_ref: nil,
            template_id: template_id,
            user: user
          }.to_json
        ).to_return(status: 200, body: { preview: '<h1>Preview</h1>' }.to_json, headers: {})
    end

    it 'retrieves a letter preview' do
      subject.create_letter_preview(
        payment_ref: payment_ref,
        template_id: template_id,
        user: user
      )

      expect have_requested(:post, "#{api_host}v1/messages/letters")
        .with(
          body: {
            payment_ref: payment_ref,
            tenancy_ref: nil,
            template_id: template_id,
            user: user
          }.to_json
        ).once
    end
  end

  context 'when successfully sending a letter' do
    before do
      stub_request(:post, "#{api_host}v1/messages/letters/send")
        .with(
          body: {
            uuid: uuid,
            user: user,
            tenancy_ref: tenancy_ref
          }.to_json
        ).to_return(status: 200, body: nil, headers: {})
    end

    it 'sends a letter' do
      subject.send_letter(uuid: uuid, user: user, tenancy_ref: tenancy_ref)

      expect have_requested(:post, "#{api_host}v1/messages/letters/send")
               .with(
                 body: {
                   uuid: uuid,
                   user: user,
                   tenancy_ref: tenancy_ref
                 }.to_json
               ).once
    end
  end

  context 'when failing to send a letter because payment_ref not found' do
    let(:not_a_pay_ref) { 'not_a_pay_ref' }

    before do
      stub_request(:post, "#{api_host}v1/messages/letters")
        .with(
          body: {
            payment_ref: not_a_pay_ref,
            tenancy_ref: nil,
            template_id: template_id,
            user: user
          }.to_json
        ).to_return(status: 404)
    end

    it 'throws 404 error' do
      expect { subject.create_letter_preview(payment_ref: not_a_pay_ref, template_id: template_id, user: user) }.to raise_error(
        Exceptions::IncomeApiError::NotFoundError,
        "[Income API error: Received 404 response] when trying to send_letter with payment_ref: '#{not_a_pay_ref}'"
      )
    end
  end

  context 'when failing to send a letter because of some application error' do
    before do
      stub_request(:post, "#{api_host}v1/messages/letters")
        .with(
          body: {
            payment_ref: payment_ref,
            tenancy_ref: nil,
            template_id: template_id,
            user: user
          }.to_json
        ).to_return(status: 500)
    end

    it 'throws 500 error' do
      expect { subject.create_letter_preview(payment_ref: payment_ref, template_id: template_id, user: user) }.to raise_error(
        Exceptions::IncomeApiError,
        '[Income API error: Received 500 response] error sending letter'
      )
    end
  end

  context 'when retrieving a list of letter templates' do
    let(:template_id) { Faker::IDNumber.valid }
    let(:name) { Faker::Games::LeagueOfLegends.location }

    before do
      user_params = {
        id: user.id,
        email: user.email,
        name: user.name,
        groups: user.groups
      }.to_param(:user)

      stub_request(:get, "#{api_host}v1/messages/letters/get_templates?#{user_params}")
        .to_return(
          status: 200,
          body: [{
                   id: template_id,
                   name: name
                 }].to_json,
          headers: {}
        )
    end

    it "get's a list of templates" do
      expect(subject.get_letter_templates(user: user)).to eq([{
        id: template_id,
        name: name
      }])
    end
  end

  context 'when failing to get letter templates' do
    let(:user_params) do
      {
        id: user.id,
        email: user.email,
        name: user.name,
        groups: user.groups
      }.to_param(:user)
    end

    before do
      stub_request(:get, "#{api_host}v1/messages/letters/get_templates?#{user_params}")
        .to_return(status: 500)
    end

    it 'throws an error' do
      expect { subject.get_letter_templates(user: user) }.to raise_error(
        Exceptions::IncomeApiError,
        "[Income API error: Received 500 response] when trying to get_letter_templates 'https://example.com/api/v1/messages/letters/get_templates?#{user_params}'"
      )
    end
  end
end
