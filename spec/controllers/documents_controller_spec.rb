require 'rails_helper'

describe DocumentsController do
  before do
    stub_authentication
  end

  let(:user_id) { 123 }
  let(:id) { Faker::Number.number(2) }
  let(:uuid) { SecureRandom.uuid }
  let(:template_id) { Faker::IDNumber.valid }
  let(:template_name) { Faker::StarTrek.character }
  let(:payment_ref) { Faker::IDNumber.valid }

  context '#show' do
    it 'downloads a document' do
      expect_any_instance_of(Hackney::Income::DocumentsGateway).to receive(:download_document).with(
        id: id
      ).and_return(Net::HTTPOK.new(1.1, 200, 'nil'))

      get :show, params: { id: id }
    end

    it 'shows an error message when a document is not found' do
      expect_any_instance_of(Hackney::Income::DocumentsGateway).to receive(:download_document).with(
        id: id
      ).and_return(Net::HTTPOK.new(1.1, 404, nil))

      get :show, params: { id: id }

      expect(flash[:notice]).to eq('Document is not found')
    end
  end

  context '#index' do
    let(:documents) { Array.new(2, example_document) }

    it 'should show a list all documents' do
      expect_any_instance_of(Hackney::Income::DocumentsGateway).to receive(:get_all).and_return(documents)

      get :index

      expect(assigns(:documents)).to eq(documents)
    end
  end
end
