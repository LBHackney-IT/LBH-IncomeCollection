require 'rails_helper'

describe AuthHelper do
  describe '#auth_provider_path' do
    context 'when in development environment' do
      before do
        allow(Rails.env).to receive(:development?).and_return(true)
      end

      context 'when MAGIC VAR is set' do
        it 'returns the developer provider path' do
          allow(ENV).to receive(:fetch).with('AUTH_NO_AZURE_AD', false).and_return(true)
          expect(helper.auth_provider_path).to eq('/auth/developer')
        end
      end

      context 'when MAGIC VAR is not set' do
        it 'returns the azure ad provider path' do
          allow(ENV).to receive(:fetch).with('AUTH_NO_AZURE_AD', false).and_return(false)
          expect(helper.auth_provider_path).to eq('/auth/azureactivedirectory')
        end
      end
    end

    context 'when not in development environment' do
      it 'returns the azure ad provider path' do
        allow(Rails.env).to receive(:development?).and_return(false)
        expect(helper.auth_provider_path).to eq('/auth/azureactivedirectory')
      end
    end
  end
end
