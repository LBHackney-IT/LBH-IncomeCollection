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

  context 'when successfully downloading a sent letter' do
    before do
      stub_request(:get, "#{api_host}v1/documents/#{id}/download").to_return(status: 200, body: 'file', headers: {})
    end

    it 'retrieves a sent letter' do
      subject.download_document(id: id)

      expect have_requested(:get, "#{api_host}v1/documents/#{id}/download").once
    end
  end

  context 'when failing to downloading a sent letter' do
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

  context 'when retrieving all saved documents' do
    let(:metadata) do
      example_metadata(
        user_id: user_id,
        payment_ref: payment_ref,
        id: template_id
      )
    end

    let(:document) do
      example_document(
        id: id,
        uuid: uuid,
        metadata: metadata.to_json
      )
    end

    before do
      stub_request(:get, "#{api_host}v1/documents/").to_return(status: 200, body: [document].to_json)
    end

    it 'get a list of all documents' do
      documents = subject.get_all
      expect have_requested(:get, "#{api_host}v1/documents").once

      expect(documents).to eq([{
                                 id: id,
                                 uuid: uuid,
                                 extension: '.pdf',
                                 metadata:  metadata,
                                 filename: "#{uuid}.pdf",
                                 mime_type: 'application/pdf',
                                 status: 'uploading',
                                 created_at: Time.parse(document[:created_at]),
                                 updated_at: Time.parse(document[:updated_at])
                               }])
    end

    context 'when payment_ref param is present' do
      before do
        stub_request(:get, "#{api_host}v1/documents/?payment_ref=1234567890").to_return(status: 200, body: [document].to_json)
      end

      it 'get a list of all documents' do
        subject.get_all(filters: { payment_ref: '1234567890' })

        expect have_requested(:get, "#{api_host}v1/documents").with(query: { payment_ref: 'payment_ref' })
      end
    end
  end
end
