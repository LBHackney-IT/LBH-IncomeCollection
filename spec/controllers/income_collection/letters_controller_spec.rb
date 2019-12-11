require 'rails_helper'

describe IncomeCollection::LettersController do
  before do
    sign_in
  end

  let(:user) { @user }
  let(:uuid) { SecureRandom.uuid }
  let(:template_id) { Faker::IDNumber.valid }
  let(:template_name) { Faker::StarTrek.character }
  let(:tenancy_ref) { Faker::IDNumber.valid }

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
    context 'shows a preview with 100 tenancy_refs' do
      let(:tenancy_refs) { Array.new(100) { Faker::IDNumber.valid } }

      before do
        expect_any_instance_of(Hackney::Income::LettersGateway).to receive(:create_letter_preview).with(
          tenancy_ref: tenancy_refs.first,
          template_id: template_id,
          payment_ref: nil,
          user: @user
        ).once.and_return(
          preview: Faker::StarTrek.villain
        )

        post :create, params: {
          template_id: template_id,
          tenancy_refs: tenancy_refs.join(random_joiner)
        }
      end

      it { expect(assigns(:preview)).to be_present }
      it { expect(assigns(:tenancy_refs)).to be_present }

      it { expect(assigns(:tenancy_refs)).to eq(tenancy_refs.reject { |r| r == tenancy_refs.first }) }
    end

    context 'shows a preview with 1 tenancy_refs' do
      let(:tenancy_refs) { [Faker::IDNumber.valid] }

      before do
        expect_any_instance_of(Hackney::Income::LettersGateway).to receive(:create_letter_preview).with(
          tenancy_ref: tenancy_refs.first,
          template_id: template_id,
          payment_ref: nil,
          user: @user
        ).once.and_return(
          preview: Faker::StarTrek.villain
        )

        post :create, params: {
          template_id: template_id,
          tenancy_refs: tenancy_refs.join(random_joiner)
        }
      end

      it { expect(assigns(:preview)).to be_present }

      it { expect(assigns(:tenancy_refs)).to eq([]) }
    end

    context 'shows preview with errors' do
      let(:preview_errors) { [{ name: 'correspondence_address_1', message: 'missing mandatory field' }] }

      before do
        expect_any_instance_of(Hackney::Income::LettersGateway).to receive(:create_letter_preview).with(
          tenancy_ref: tenancy_ref,
          template_id: template_id,
          payment_ref: nil,
          user: @user
        ).and_return(Net::HTTPOK.new(1.1, 200, {
          errors: preview_errors
        }.to_json))

        post :create, params: {
          template_id: template_id,
          tenancy_refs: [tenancy_ref].join(random_joiner)
        }
      end

      it { expect(assigns(:preview)).to be_present }
      it { expect(assigns(:preview).message).to eq({ errors: preview_errors }.to_json) }
    end

    context 'failing to generate preview' do
      it 'show me an error message when tenancy reference is not found' do
        expect_any_instance_of(Hackney::Income::LettersGateway).to receive(:create_letter_preview).with(
          tenancy_ref: tenancy_ref,
          template_id: template_id,
          payment_ref: nil,
          user: @user
        ).and_raise(Exceptions::IncomeApiError::NotFoundError, 'Not Found')

        post :create, params: {
          template_id: template_id,
          tenancy_refs: [tenancy_ref].join(random_joiner)
        }

        expect(flash[:notice]).to eq('Tenancy Reference not found')
      end

      it 'show me an error message when tenancy reference is not supplied' do
        post :create, params: {
          template_id: template_id
        }

        expect(flash[:notice]).to eq('Param is missing or the value is empty: tenancy_refs')
      end
    end
  end

  context '#send_letter' do
    before do
      expect_any_instance_of(Hackney::Income::LettersGateway).to receive(:send_letter).with(
        uuid: uuid,
        user: @user,
        tenancy_ref: tenancy_ref
      ).and_return(Net::HTTPOK.new(1.1, 204, nil))
    end

    context 'when format is html' do
      it 'successfully sends a letter' do
        post :send_letter, params: {
          uuid: uuid,
          user: @user,
          tenancy_ref: tenancy_ref
        }
        expect(response).to redirect_to(new_income_collection_letter_path)
        expect(flash[:notice]).to eq('Successfully sent')
      end
    end

    context 'when format is js' do
      it 'successfully sends and renders js' do
        post :send_letter, format: :js, params: {
          uuid: uuid,
          user: @user,
          tenancy_ref: tenancy_ref
        }

        expect(assigns[:letter_uuid]).not_to be_nil
        expect(response.successful?).to be_truthy
        expect(response).to render_template(:send_letter)
      end
    end
  end
end
