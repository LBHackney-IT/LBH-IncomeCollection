require 'rails_helper'

describe 'Sending a letter manually', type: :request do
  let(:uuid) { SecureRandom.uuid }
  let(:tenancy_ref) { Faker::Lorem.characters(number: 6) }
  let(:user_id) { SecureRandom.uuid }
  let(:groups) { ['income-collection-group-1'] }

  before do
    jwt_token = build_jwt_token(groups: groups, user_id: user_id)
    cookies['hackneyToken'] = jwt_token
  end

  context 'with a income collection user' do
    it 'will send a letter successfully if a uuid and tenancy_ref is provided' do
      stub_sending_successful_letter_response
      post send_letter_income_collection_letter_path(uuid: uuid, tenancy_ref: tenancy_ref)
      expect(response.request.parameters).to eq(
        'action' => 'send_letter',
        'controller' => 'income_collection/letters',
        'tenancy_ref' => tenancy_ref,
        'uuid' => uuid
      )
    end

    it 'will error if no tenancy_ref is provided' do
      post send_letter_income_collection_letter_path(uuid: uuid, tenancy_ref: nil)
      expect(flash[:notice]).to eq('Param is missing or the value is empty: tenancy_ref')
    end
  end

  private

  def stub_sending_successful_letter_response
    stub_request(:post, 'https://example.com/income/apiv1/messages/letters/send')
    .with(
      body: {
        uuid: uuid,
        user: {
          id: user_id,
          name: 'Hackney User',
          email: 'hackney.user@test.hackney.gov.uk',
          groups: ['income-collection-group-1']
        },
        tenancy_ref: tenancy_ref
      }.to_json
    ).to_return(status: 204, body: '', headers: {})
  end
end
