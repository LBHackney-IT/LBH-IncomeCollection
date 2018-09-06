require 'rails_helper'

describe 'creating action diary entry' do
  let(:provider_uid) { Faker::Number.number(12).to_s }
  let(:extra_hash) { { 'raw_info' => { 'id_token' => "#{Faker::Number.number(6)}.123456ABC" } } }
  let(:info_hash) do
    {
      'name' => Faker::StarTrek.character,
      'email' => "#{Faker::StarTrek.character}@enterprise.fed.gov",
      'first_name' => Faker::StarTrek.specie,
      'last_name' => Faker::StarTrek.villain
    }
  end

  before { stub_use_cases }
  around do |example|
    stub_authentication do
      example.run
    end
  end

  context 'filling in the form as a user' do
    it 'should display the form and pass through the hidden and custom values' do
      expect_any_instance_of(Hackney::Income::CreateActionDiaryEntry).to receive(:execute).with(
        tenancy_ref: '1234567',
        balance: '1200.99',
        code: 'GEN',
        type: '',
        date: Date.today.strftime("%YYYY-%MM-%DD"),
        comment: 'Test comment.',
        universal_housing_username: info_hash.fetch('name')
      )

      visit '/auth/azureactivedirectory'
      visit action_diary_entry_path(id: '1234567')

      expect(page).to have_field('comment')
      expect(page).to have_field('code')

      select('General Note', from: 'code')

      fill_in 'comment', with: 'Test comment.'
      click_button 'Create'
    end
  end

  def stub_authentication(&block)
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:azureactivedirectory)
    OmniAuth.config.mock_auth[:azureactivedirectory] = OmniAuth::AuthHash.new(
      'provider' => 'azureactivedirectory',
      'uid' => provider_uid,
      'info' => info_hash,
      'extra' => extra_hash
    )

    ENV['IC_STAFF_GROUP'] = '123456ABC'

    block.call

    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth.delete(:azureactivedirectory)
    Rails.application.env_config.delete('omniauth.auth')

    ENV['IC_STAFF_GROUP'] = nil
  end

  def stub_use_cases
    stub_const('Hackney::Income::LessDangerousTenancyGateway', Hackney::Income::StubTenancyGatewayBuilder.build_stub)
    stub_const('Hackney::Income::CreateActionDiaryEntry', Hackney::Income::StubCreateActionDiaryEntry)
    stub_const('Hackney::Income::ActionDiaryEntryGateway', Hackney::Income::StubActionDiaryEntryGateway)
    allow_any_instance_of(Hackney::Income::TransactionsGateway).to receive(:transactions_for).and_return([])
  end
end
