require 'rails_helper'

describe LettersController do
  before do
    stub_authentication
  end

  let(:user_id) { 123 }
  let(:template_id) { Faker::IDNumber.valid }
  let(:template_name) { Faker::StarTrek.character }
  let(:payment_ref) { Faker::IDNumber.valid }

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
    it 'shows preview' do
      expect_any_instance_of(Hackney::Income::LettersGateway).to receive(:send_letter).with(
        payment_ref: payment_ref,
        template_id: template_id,
        user_id: user_id
      ).and_return(Net::HTTPOK.new(1.1, 200, nil))

      post :preview, params: {
        template_id: template_id,
        pay_ref: payment_ref
      }
    end

    it 'shows preview errors' do
      expect_any_instance_of(Hackney::Income::LettersGateway).to receive(:send_letter).with(
        payment_ref: payment_ref,
        template_id: template_id,
        user_id: user_id
      ).and_return(Net::HTTPOK.new(1.1, 200, {
        errors: [{ field: 'correspondence_address_1', error: 'missing mandatory field' }]
      }.to_json))

      post :preview, params: {
        template_id: template_id,
        pay_ref: payment_ref
      }
    end

    context 'failing to generate preview' do
      it 'show me an error message when payment reference is not found' do
        expect_any_instance_of(Hackney::Income::LettersGateway).to receive(:send_letter).with(
          payment_ref: payment_ref,
          template_id: template_id,
          user_id: user_id
        ).and_raise(Exceptions::IncomeApiError::NotFoundError, 'Not Found')

        post :preview, params: {
          template_id: template_id,
          pay_ref: payment_ref
        }

        expect(flash[:notice]).to eq('Payment reference not found')
      end

      it 'show me an error message when payment reference is not supplied' do
        post :preview, params: {
          template_id: template_id
        }

        expect(flash[:notice]).to eq('Param is missing or the value is empty: pay_ref')
      end
    end
  end
end
