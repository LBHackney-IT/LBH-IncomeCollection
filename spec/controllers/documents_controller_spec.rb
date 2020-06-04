require 'rails_helper'

describe DocumentsController do
  before { sign_in }

  let(:id) { Faker::Number.number(digits: 2).to_s }
  let(:document_response) { Net::HTTPResponse.new(1.1, 200, 'OK') }
  let(:res_body) { Faker::DcComics.villain }
  let(:res_content_type) { 'application/pdf' }
  let(:res_content_disposition) { "attachment; filename=\"#{Faker::Games::LeagueOfLegends.location}.pdf\"" }

  context '#show' do
    context 'when downloading document' do
      let(:params) { { id: id } }

      before do
        document_response['Content-Disposition'] = res_content_disposition
        allow(document_response).to receive(:body).and_return(res_body)
        allow(document_response).to receive(:content_type).and_return(res_content_type)

        expect_any_instance_of(Hackney::Income::DocumentsGateway)
          .to receive(:download_document)
          .with(id: id, username: @user.name, documents_view: nil)
          .and_return(document_response)

        get :show, params: params
      end

      it { expect(response.content_type).to eq(res_content_type) }
      it { expect(response.header['Content-Disposition']).to eq(res_content_disposition) }
      it { expect(response.body).to eq(res_body) }

      context 'and when the inline param is present' do
        let(:params) { { id: id, inline: true } }

        it 'has Content Disposition as `inline`' do
          expect(response.header['Content-Disposition']).to eq('inline')
        end
      end
    end

    context 'when downloading document from the document view' do
      let(:params) { { id: id, documents_view: true } }

      before do
        document_response['Content-Disposition'] = res_content_disposition
        allow(document_response).to receive(:body).and_return(res_body)
        allow(document_response).to receive(:content_type).and_return(res_content_type)

        expect_any_instance_of(Hackney::Income::DocumentsGateway)
          .to receive(:download_document)
          .with(id: id, username: @user.name, documents_view: 'true')
          .and_return(document_response)

        get :show, params: params
      end

      it { expect(response.content_type).to eq(res_content_type) }
      it { expect(response.header['Content-Disposition']).to eq(res_content_disposition) }
      it { expect(response.body).to eq(res_body) }
    end

    context 'when not found' do
      before do
        expect_any_instance_of(Hackney::Income::DocumentsGateway)
          .to receive(:download_document)
          .and_return(Net::HTTPOK.new(1.1, 404, nil))

        get :show, params: { id: id }
      end

      it { expect(response).to redirect_to documents_path }
      it { expect(flash[:notice]).to eq('Document not found') }
    end
  end

  context '#index' do
    let(:received_document) { example_document(status: :received) }
    let(:downloaded_document) { example_document(status: :downloaded) }
    let(:documents) { [received_document, downloaded_document] }
    let(:default_filters) { { documents_per_page: 20, page_number: 1, payment_ref: nil, status: nil } }

    it 'should all the use case with appropriate default params ' do
      expect_any_instance_of(Hackney::Income::GetAllDocuments).to receive(:execute).with(filters: default_filters)
        .and_return(documents: documents, number_of_pages: 1)

      get :index

      expect(assigns(:documents)).to eq(documents)
    end

    context 'when payment_ref param is present' do
      let(:payment_ref) { Faker::IDNumber.valid }
      let(:filters_with_payment_ref) { default_filters.merge(payment_ref: payment_ref) }

      it 'should show a list all documents' do
        expect_any_instance_of(Hackney::Income::GetAllDocuments)
          .to receive(:execute).with(filters: filters_with_payment_ref)
                .and_return(documents: documents, number_of_pages: 1)

        get :index, params: { payment_ref: payment_ref }

        expect(assigns(:documents)).to eq(documents)
      end
    end

    context 'when status param is present' do
      let(:filters_with_payment_ref) { default_filters.merge(status: 'downloaded') }

      it 'should show a list all documents' do
        expect_any_instance_of(Hackney::Income::GetAllDocuments)
          .to receive(:execute).with(filters: filters_with_payment_ref)
                .and_return(documents: [downloaded_document], number_of_pages: 1)

        get :index, params: { status: 'downloaded' }

        expect(assigns(:documents)).to eq([downloaded_document])
      end
    end
  end

  context '#review_failure' do
    context 'when successfully reviewed' do
      it 'should show a success message' do
        expect_any_instance_of(Hackney::Income::DocumentsGateway)
          .to receive(:review_failure).with(document_id: id).and_return(document_response)

        patch :review_failure, params: { id: id }

        expect(flash[:notice]).to eq('Successfully marked as reviewed')
      end
    end

    context 'when not successfully reviewed' do
      let(:document_response) { Net::HTTPResponse.new(1.1, 400, 'NOT OK') }

      it 'should show an error message' do
        expect_any_instance_of(Hackney::Income::DocumentsGateway)
          .to receive(:review_failure)
                .and_raise(
                  Exceptions::IncomeApiError::NotFoundError.new(document_response),
                  "when trying to mark document #{id} as reviewed"
                )

        patch :review_failure, params: { id: id }

        expect(flash[:notice]).to eq("An error occurred while marking document #{id} as reviewed")
      end
    end
  end
end
