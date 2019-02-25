require 'rails_helper'

describe Hackney::Income::LettersGateway do
  let(:api_key) { 'FAKE_API_KEY-53822c9d-b17d-442d-ace7-565d08215d20-53822c9d-b17d-442d-ace7-565d08215d20' }
  let(:api_host) { 'https://example.com/api/' }

  subject { described_class.new( api_key: api_key, api_host: api_host) }

  context 'when sending a letter' do
    let(:tenancy_ref) { "#{Faker::Number.number(8)}/#{Faker::Number.number(2)}" }
    let(:template_id) { Faker::LeagueOfLegends.location }

    before do
      stub_request(:post, "#{api_host}v1/letters/send_letter")
        .with(
          body: {
            tenancy_ref: tenancy_ref,
            template_id: template_id,
            user_id: 123
          }.to_json
        ).to_return(status: 200, body: '', headers: {})
    end

    it 'should send a letter' do
      subject.send_letter(
        tenancy_ref: tenancy_ref,
        template_id: template_id,
        user_id: 123
      )

      expect have_requested(:post, "#{api_host}v1/letters/send_letter")
        .with(
          body: {
            tenancy_ref: tenancy_ref,
            template_id: template_id,
            user_id: 123,
          }.to_json
        ).once
    end
  end

  context 'when retrieving a list of letter templates' do
    let(:template_id) { Faker::IDNumber.valid }
    let(:name) { Faker::LeagueOfLegends.location }

    before do
      stub_request(:get, "#{api_host}v1/letters/get_templates")
        .to_return(
          status: 200,
          body: [{
                   id: template_id,
                   name: name,
                 }].to_json,
          headers: {}
        )
    end

    it 'should return a list of templates' do
      expect(subject.get_letter_templates).to eq([{
        id: template_id,
        name: name,
      }])
    end
  end

  context 'when failing to get letter templates' do
    before do
      stub_request(:get, "#{api_host}v1/letters/get_templates")
        .to_return(status: 500)
    end

    it 'should throw an error' do
      expect { subject.get_letter_templates }.to raise_error(
        Exceptions::IncomeApiError,
        "[Income API error: Received 500 response] when trying to get_letter_templates 'https://example.com/api/v1/letters/get_templates'"
      )
    end
  end
end
