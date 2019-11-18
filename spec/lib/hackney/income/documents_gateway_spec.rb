require 'rails_helper'

describe Hackney::Income::DocumentsGateway do
  let(:api_key) { 'FAKE_API_KEY-53822c9d-b17d-442d-ace7-565d08215d20-53822c9d-b17d-442d-ace7-565d08215d20' }
  let(:api_host) { 'https://example.com/api/' }
  let(:template_id) { Faker::LeagueOfLegends.location }
  let(:payment_ref) { Faker::Number.number(8) }
  let(:uuid) { SecureRandom.uuid }
  let(:id) { Faker::Number.number(2) }

  subject { described_class.new(api_key: api_key, api_host: api_host) }

  context 'downloading a letter' do
    before do
      stub_request(:get, "#{api_host}v1/documents/#{id}/download")
        .with(query: { username: username })
        .to_return(status: 200, body: 'file', headers: {})

      subject.download_document(id: id, username: username)
    end

    context 'with a username' do
      let(:username) { Faker::Lorem.characters(10) }

      it 'calls the correct endpoint with a username' do
        expect(WebMock).to have_requested(:get, "#{api_host}v1/documents/#{id}/download?username=#{username}").once
      end
    end

    context 'without a username' do
      let(:username) { nil }

      it 'does not make a web request' do
        expect(WebMock).to_not have_requested(:any, /.*/)
      end
    end
  end

  context 'when trying to download a letter than does not exist' do
    before do
      stub_request(:get, "#{api_host}v1/documents/#{id}/download")
        .with(query: hash_including({}))
        .to_return(status: 404)
    end

    it 'throws a custom NotFoundErrr' do
      expect { subject.download_document(id: id, username: 'example') }
        .to raise_error(
          Exceptions::IncomeApiError::NotFoundError,
          "[Income API error: Received 404 response] when trying to download_letter with id: '#{id}'"
        )
    end
  end

  context 'when retrieving all saved documents' do
    let(:metadata) do
      example_metadata(
        user_id: 1,
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
      expect(WebMock).to have_requested(:get, "#{api_host}v1/documents/").once

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

    context 'with a payment reference parameter' do
      before do
        stub_request(:get, "#{api_host}v1/documents/?payment_ref=1234567890").to_return(status: 200, body: [document].to_json)
      end

      it 'passes a filter to the documents endpoint' do
        subject.get_all(filters: { payment_ref: '1234567890' })

        expect(WebMock).to have_requested(:get, "#{api_host}v1/documents/").with(query: { payment_ref: '1234567890' })
      end
    end
  end
end
