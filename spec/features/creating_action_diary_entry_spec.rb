require 'rails_helper'

describe 'creating action diary entry' do
  let!(:provider_uid) { Faker::Number.number(12).to_s }
  let!(:info_hash) do
    {
      'name' => Faker::StarTrek.character,
      'email' => "#{Faker::StarTrek.character}@enterprise.fed.gov",
      'first_name' => Faker::StarTrek.specie,
      'last_name' => Faker::StarTrek.villain
    }
  end
  let!(:extra_hash) do
    {
      'raw_info' =>
      {
        'id_token' => "#{Faker::Number.number(6)}.123456ABC"
      }
    }
  end

  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock('azureactivedirectory')
    OmniAuth.config.mock_auth['azureactivedirectory'] = OmniAuth::AuthHash.new(
      'provider' => 'azureactivedirectory',
      'uid' => provider_uid,
      'info' => info_hash,
      'extra' => extra_hash
    )

    ENV['IC_STAFF_GROUP'] = '123456ABC'

    stub_const('Hackney::Income::SqlUsersGateway', Hackney::Income::StubSqlUsersGateway)
    stub_const('Hackney::Income::LessDangerousTenancyGateway', Hackney::Income::StubTenancyGatewayBuilder.build_stub)
    stub_const('Hackney::Income::CreateActionDiaryEntry', Hackney::Income::StubCreateActionDiaryEntry)
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth.delete('azureactivedirectory')
    Rails.application.env_config.delete('omniauth.auth')
  end

  context 'filling in the form as a user' do
    it 'should display the form and pass through the hidden and custom values' do
      expect_any_instance_of(Hackney::Income::CreateActionDiaryEntry).to receive(:execute).with(
        tenancy_ref: '1234567',
        balance: '1200.99',
        code: 'Z00',
        type: 'SYS',
        comment: 'Test comment.',
        universal_housing_username: 'Example User'
      )

      visit '/auth/azureactivedirectory'
      visit action_diary_entry_path(id: '1234567')

      expect(page).to have_field('comment')
      expect(page).to have_field('type')
      expect(page).to have_field('code')

      # within('/html/body') do
      select('SYS', from: 'type')
      select('Z00', from: 'code')

      fill_in 'comment', with: 'Test comment.'
      click_button 'Create'

      p page.body
      # expect(response).to redirect_to(tenancy_path(id: '1234567'))
      # expect(flash[:notice]).to eq('Successfully created an action diary entry')
      # end
    end
  end
end
