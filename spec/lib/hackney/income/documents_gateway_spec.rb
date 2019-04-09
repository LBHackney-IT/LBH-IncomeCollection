require 'rails_helper'

describe Hackney::Income::DocumentsGateway do
  let(:api_key) { 'FAKE_API_KEY-53822c9d-b17d-442d-ace7-565d08215d20-53822c9d-b17d-442d-ace7-565d08215d20' }
  let(:api_host) { 'https://example.com/api/' }
  let(:template_id) { Faker::LeagueOfLegends.location }
  let(:user_id) { Faker::Number.number(4) }
  let(:payment_ref) { Faker::Number.number(8) }
  let(:uuid) { SecureRandom.uuid }
  let(:id) { Faker::Number.number(2) }

  subject { described_class.new(api_key: api_key, api_host: api_host) }

  context 'when successfully retrieving a sent letter' do
    before do
      stub_request(:get, "#{api_host}v1/documents/#{id}/download").to_return(status: 200, body: 'file', headers: {})
    end

    it 'retrieves a sent letter' do
      subject.download_document(id: id)

      expect have_requested(:get, "#{api_host}v1/documents/#{id}/download").once
    end
  end

  context 'when failing to retrieve a sent letter' do
    before do
      stub_request(:get, "#{api_host}v1/documents/#{id}/download").to_return(status: 404)
    end

    it 'throws 404 error' do
      expect { subject.download_document(id: id) }.to raise_error(
        Exceptions::IncomeApiError::NotFoundError,
        "[Income API error: Received 404 response] when trying to download_letter with id: '#{id}'"
      )
    end
  end

end
