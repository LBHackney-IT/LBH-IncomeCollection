require 'rails_helper'

describe AuthHelper do
  describe '#auth_provider_path' do
    before do
      allow(Rails.env).to receive(:development?).and_return(rails_env)
    end

    context 'when in development environment' do
      let(:rails_env) { true }

      before do
        allow(ENV).to receive(:fetch).with('AUTH_NO_AZURE_AD', false).and_return(auth_no_azure_ad)
      end

      context 'when AUTH_NO_AZURE_AD is set' do
        let(:auth_no_azure_ad) { true }

        it 'returns the developer provider path' do
          expect(helper.auth_provider_path).to eq('/auth/developer')
        end
      end

      context 'when AUTH_NO_AZURE_AD is not set' do
        let(:auth_no_azure_ad) { false }

        it 'returns the azure ad provider path' do
          expect(helper.auth_provider_path).to eq('/auth/azureactivedirectory')
        end
      end
    end

    context 'when not in development environment' do
      let(:rails_env) { false }

      it 'returns the azure ad provider path' do
        expect(helper.auth_provider_path).to eq('/auth/azureactivedirectory')
      end
    end
  end
end
