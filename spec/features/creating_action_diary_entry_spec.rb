require 'rails_helper'

describe 'creating action diary entry' do
  let(:username) { Faker::StarTrek.character }

  before { stub_use_cases }
  around do |example|
    with_mock_authentication(username: username) { example.run }
  end

  context 'filling in the form as a user' do
    it 'should display the form and pass through the hidden and custom values' do
      expect_any_instance_of(Hackney::Income::CreateActionDiaryEntry).to receive(:execute).with(
        tenancy_ref: '1234567',
        balance: '1200.99',
        code: 'DEB',
        type: '',
        date: Date.today.strftime('%YYYY-%MM-%DD'),
        comment: 'Test comment.',
        universal_housing_username: username
      )

      visit '/auth/azureactivedirectory'
      visit action_diary_entry_path(id: '1234567')

      expect(page).to have_field('comment')
      expect(page).to have_field('code')

      select('Referred for debt advice', from: 'code')

      fill_in 'comment', with: 'Test comment.'
      click_button 'Add action'
    end
  end

  def stub_use_cases
    stub_const('Hackney::Income::TenancyGateway', Hackney::Income::StubTenancyGatewayBuilder.build_stub)
    stub_const('Hackney::Income::CreateActionDiaryEntry', Hackney::Income::StubCreateActionDiaryEntry)
    stub_const('Hackney::Income::ActionDiaryEntryGateway', Hackney::Income::StubActionDiaryEntryGateway)
    allow_any_instance_of(Hackney::Income::TransactionsGateway).to receive(:transactions_for).and_return([])
    stub_const('Hackney::Income::IncomeApiUsersGateway', Hackney::Income::StubIncomeApiUsersGateway)
  end
end
