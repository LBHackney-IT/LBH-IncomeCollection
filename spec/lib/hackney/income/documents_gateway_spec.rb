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
    let(:documents_view) { nil }
    before do
      stub_request(:get, "#{api_host}v1/documents/#{id}/download")
        .with(query: { username: username, documents_view: documents_view })
        .to_return(status: 200, body: 'file', headers: {})

      subject.download_document(id: id, username: username, documents_view: documents_view)
    end

    context 'with a username' do
      let(:username) { Faker::Lorem.characters(10) }

      it 'calls the correct endpoint with a username and documents view' do
        expect(WebMock).to have_requested(:get, "#{api_host}v1/documents/#{id}/download?username=#{username}&documents_view#{documents_view}").once
      end
    end

    context 'without a username' do
      let(:username) { nil }

      it 'does not make a web request' do
        expect(WebMock).to_not have_requested(:any, /.*/)
      end
    end
  end

  context 'downloading a from documents view' do
    let(:documents_view) { true }
    before do
      stub_request(:get, "#{api_host}v1/documents/#{id}/download")
        .with(query: { username: username, documents_view: documents_view })
        .to_return(status: 200, body: 'file', headers: {})

      subject.download_document(id: id, username: username, documents_view: documents_view)
    end

    context 'with a username' do
      let(:username) { Faker::Lorem.characters(10) }

      it 'calls the correct endpoint with a username and documents view' do
        expect(WebMock).to have_requested(:get, "#{api_host}v1/documents/#{id}/download?username=#{username}&documents_view=#{documents_view}").once
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
      expect { subject.download_document(id: id, username: 'example', documents_view: nil) }
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

    let(:default_filters) { { documents_per_page: 20, page_number: 1 } }

    before do
      stub_request(:get, "#{api_host}v1/documents/?documents_per_page=20&page_number=1")
        .to_return(status: 200, body: { documents: [document] }.to_json)
    end

    it 'get a list of all documents' do
      response = subject.get_all(filters: default_filters)

      expect(WebMock).to have_requested(:get, "#{api_host}v1/documents/").with(query: default_filters)

      expect(response[:documents]).to eq([{
                                 id: id,
                                 uuid: uuid,
                                 extension: '.pdf',
                                 metadata: metadata.to_json,
                                 filename: "#{uuid}.pdf",
                                 mime_type: 'application/pdf',
                                 status: 'uploading',
                                 created_at: document[:created_at],
                                 updated_at: document[:updated_at]
                               }])
    end

    context 'with a payment reference parameter' do
      before do
        stub_request(:get, "#{api_host}v1/documents/?payment_ref=1234567890")
          .to_return(status: 200, body: { documents: [document] }.to_json)
      end

      it 'passes a filter to the documents endpoint' do
        subject.get_all(filters: { payment_ref: '1234567890' })

        expect(WebMock).to have_requested(:get, "#{api_host}v1/documents/").with(query: { payment_ref: '1234567890' })
      end
    end

    context 'with a status parameter' do
      before do
        stub_request(:get, "#{api_host}v1/documents/?status=downloaded")
          .to_return(status: 200, body: { documents: [document] }.to_json)
      end

      it 'passes a filter to the documents endpoint' do
        subject.get_all(filters: { status: 'downloaded' })

        expect(WebMock).to have_requested(:get, "#{api_host}v1/documents/").with(query: { status: 'downloaded' })
      end
    end
  end

  context 'when marking document as reviewed' do
    before do
      stub_request(:patch, "#{api_host}v1/documents/#{id}/review_failure").to_return(status: 200)
    end

    it 'passes the id to the review_failure endpoint' do
      subject.review_failure(document_id: id)

      expect(WebMock).to have_requested(:patch, "#{api_host}v1/documents/#{id}/review_failure")
    end

    context 'when failed to mark document as reviewed' do
      before do
        stub_request(:patch, "#{api_host}v1/documents/#{id}/review_failure").to_return(status: 500)
      end

      it 'throws an error' do
        expect { subject.review_failure(document_id: id) }
          .to raise_error(
            Exceptions::IncomeApiError::NotFoundError,
            "[Income API error: Received 500 response] when trying to mark document #{id} as reviewed"
          )
      end
    end
  end
end
