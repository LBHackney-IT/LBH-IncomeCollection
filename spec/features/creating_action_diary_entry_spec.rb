require 'rails_helper'

describe 'creating action diary entry' do
  let(:username) { Faker::StarTrek.character }
  let(:provider_uid) { Faker::Number.number(12).to_s }
  let(:stub_user_id) { Hackney::Income::StubIncomeApiUsersGateway.generate_id(provider_uid: provider_uid, name: username) }

  let(:create_action_diary_entry_double) { instance_double(Hackney::Income::CreateActionDiaryEntry) }
  let(:create_action_diary_entry_class) { class_double(Hackney::Income::CreateActionDiaryEntry) }

  before do
    allow(create_action_diary_entry_class).to receive(:new).and_return(create_action_diary_entry_double)
    stub_const('Hackney::Income::CreateActionDiaryEntry', create_action_diary_entry_class)
    stub_use_cases
    stub_income_api_actions
  end

  around do |example|
    with_mock_authentication(attributes: { uid: provider_uid, info: { name: username } }) { example.run }
  end

  context 'filling in the form as a user' do
    it 'should display the form and call the usecase ' do
      expect(create_action_diary_entry_double).to receive(:execute).with(
        tenancy_ref: '1234567',
        action_code: 'DEB',
        comment: 'Test comment.',
        user_id: stub_user_id
      )

      visit '/auth/azureactivedirectory'
      visit action_diary_entry_path(tenancy_ref: '1234567')

      expect(page).to have_field('comment')
      expect(page).to have_field('code')

      select('Referred for debt advice', from: 'code')

      fill_in 'comment', with: 'Test comment.'
      click_button 'Add action'
    end
  end

  def stub_income_api_actions
    body = {
      arrears_action_diary_events: [
        {
          code: 'INC',
          date: '01-01-2019',
          comment: 'Example details of a particular call',
          universal_housing_username: 'Thomas Mcinnes'
        },
        {
          code: 'INC',
          date: '01-01-2010',
          universal_housing_username: 'Gracie Barnes'
        }
      ]
    }.to_json

    stub_request(:get, 'https://example.com/tenancy/api/v1/tenancies/1234567/actions')
      .with(headers: { 'X-Api-Key' => ENV['INCOME_COLLECTION_API_KEY'] })
      .to_return(status: 200, body: body)
  end

  def stub_use_cases
    stub_const('Hackney::Income::TenancyGateway', Hackney::Income::StubTenancyGatewayBuilder.build_stub)
    stub_const('Hackney::Income::CreateActionDiaryEntryGateway', Hackney::Income::StubActionDiaryEntryGateway)
    allow_any_instance_of(Hackney::Income::TransactionsGateway).to receive(:transactions_for).and_return([])
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)
  end
end
