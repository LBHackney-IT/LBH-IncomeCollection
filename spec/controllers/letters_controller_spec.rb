require 'rails_helper'

describe LettersController do
  before do
    stub_authentication
  end

  let(:user_id) { 123 }
  let(:uuid) { SecureRandom.uuid }
  let(:template_id) { Faker::IDNumber.valid }
  let(:template_name) { Faker::StarTrek.character }
  let(:payment_ref) { Faker::IDNumber.valid }

  let(:random_spaces) { ' ' * rand(1..10) }

  let(:random_joiner) { ["\n", ',', ';', random_spaces].sample }

  context '#new' do
    it 'assigns a list of valid templates' do
      expect_any_instance_of(Hackney::Income::LettersGateway)
        .to receive(:get_letter_templates).and_return([{ id: template_id, name: template_name }])

      get :new

      expect(assigns(:letter_templates)).to all(be_instance_of(Hackney::LetterTemplate))
      expect(assigns(:letter_templates)).to all(be_valid)
    end
  end

  context '#preview' do
    context 'shows a preview' do
      let(:payment_refs) { Array.new(100) { Faker::IDNumber.valid } }

      before do
        expect_any_instance_of(Hackney::Income::LettersGateway).to receive(:create_letter_preview).with(
          payment_ref: payment_refs.first,
          template_id: template_id,
          user_id: user_id
        ).and_return(Net::HTTPOK.new(1.1, 200, nil))

        post :preview, params: {
          template_id: template_id,
          pay_refs: payment_refs.join(random_joiner)
        }
      end

      it { expect(assigns(:preview)).to be_present }
      it { expect(assigns(:payment_refs)).to be_present }

      it { expect(assigns(:payment_refs)).to eq(payment_refs.reject { |r| r == payment_refs.first }) }

      it 'should ' do
        expect(true).to eq(true)
      end
    end

    context 'shows preview with errors' do
      let(:preview_errors) { [{ name: 'correspondence_address_1', message: 'missing mandatory field' }] }

      before do
        expect_any_instance_of(Hackney::Income::LettersGateway).to receive(:create_letter_preview).with(
          payment_ref: payment_ref,
          template_id: template_id,
          user_id: user_id
        ).and_return(Net::HTTPOK.new(1.1, 200, {
          errors: preview_errors
        }.to_json))

        post :preview, params: {
          template_id: template_id,
          pay_refs: [payment_ref].join(random_joiner)
        }
      end

      it { expect(assigns(:preview)).to be_present }
      it { expect(assigns(:preview).message).to eq({ errors: preview_errors }.to_json) }
    end

    context 'failing to generate preview' do
      it 'show me an error message when payment reference is not found' do
        expect_any_instance_of(Hackney::Income::LettersGateway).to receive(:create_letter_preview).with(
          payment_ref: payment_ref,
          template_id: template_id,
          user_id: user_id
        ).and_raise(Exceptions::IncomeApiError::NotFoundError, 'Not Found')

        post :preview, params: {
          template_id: template_id,
          pay_refs: [payment_ref].join(random_joiner)
        }

        expect(flash[:notice]).to eq('Payment reference not found')
      end

      it 'show me an error message when payment reference is not supplied' do
        post :preview, params: {
          template_id: template_id
        }

        expect(flash[:notice]).to eq('Param is missing or the value is empty: pay_refs')
      end
    end
  end

  context '#send_letter' do
    before do
      expect_any_instance_of(Hackney::Income::LettersGateway).to receive(:send_letter).with(
        uuid: uuid,
        user_id: user_id
      ).and_return(Net::HTTPOK.new(1.1, 204, nil))
    end

    context 'when format is html' do
      it 'successfully sends a letter' do
        post :send_letter, params: {
          uuid: uuid,
          user_id: user_id
        }
        expect(response).to redirect_to(letters_new_path)
        expect(flash[:notice]).to eq('Successfully sent')
      end
    end

    context 'when format is js' do
      it 'successfully sends and renders js' do
        post :send_letter, format: :js, params: {
          uuid: uuid,
          user_id: user_id
        }

        expect(assigns[:letter_uuid]).not_to be_nil
        expect(response.successful?).to be_truthy
        expect(response).to render_template(:send_letter)
      end
    end
  end
end
