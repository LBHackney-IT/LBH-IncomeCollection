require 'rails_helper'

describe DocumentsController do
  before do
    sign_in
  end

  let(:user_id) { 123 }
  let(:id) { Faker::Number.number(2) }
  let(:uuid) { SecureRandom.uuid }
  let(:template_id) { Faker::IDNumber.valid }
  let(:template_name) { Faker::StarTrek.character }
  let(:payment_ref) { Faker::IDNumber.valid }

  let(:document_response) { Net::HTTPResponse.new(1.1, 200, 'OK') }
  let(:res_body) { Faker::StarTrek.villain }
  let(:res_content_type) { 'application/pdf' }
  let(:res_content_disposition) { "attachment; filename=\"#{Faker::StarTrek.location}.pdf\"" }

  context '#show' do
    context 'when downloading document' do
      let(:params) { { id: id } }

      before do
        document_response['Content-Disposition'] = res_content_disposition
        allow(document_response).to receive(:body).and_return(res_body)
        allow(document_response).to receive(:content_type).and_return(res_content_type)

        expect_any_instance_of(Hackney::Income::DocumentsGateway).to receive(:download_document).with(
          id: id
        ).and_return(document_response)

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

    context 'when not found' do
      before do
        expect_any_instance_of(Hackney::Income::DocumentsGateway).to receive(:download_document).with(
          id: id
        ).and_return(Net::HTTPOK.new(1.1, 404, nil))

        get :show, params: { id: id }
      end

      it { expect(response).to redirect_to documents_path }

      it { expect(flash[:notice]).to eq('Document not found') }
    end
  end

  context '#index' do
    let(:documents) { Array.new(2, example_document) }

    it 'should show a list all documents' do
      expect_any_instance_of(Hackney::Income::DocumentsGateway).to receive(:get_all).and_return(documents)

      get :index

      expect(assigns(:documents)).to eq(documents)
    end

    context 'when payment_ref param is present' do
      it 'should show a list all documents' do
        expect_any_instance_of(Hackney::Income::DocumentsGateway)
          .to receive(:get_all).with(filters: { payment_ref: '1234567890' }).and_return(documents)

        get :index, params: { payment_ref: '1234567890' }

        expect(assigns(:documents)).to eq(documents)
      end
    end
  end
end
