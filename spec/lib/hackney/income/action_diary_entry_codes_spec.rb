require_relative '../../../../lib/hackney/income/action_diary_entry_codes'

describe Hackney::Income::ActionDiaryEntryCodes do
  context 'code_dropdown_options' do
    it 'finds valid codes' do
      expect(described_class.code_dropdown_options)
        .to match_array([
                          ['Direct Debit Cancelled', 'DDC'],
                          ['Financial Inclusion Call', 'FIC'],
                          ['Financial Inclusion Interview', 'FIO'],
                          ['Financial Inclusion Visit', 'FIV'],
                          ['HB Outstanding', 'HBO'],
                          ['Incoming telephone call', 'INC'],
                          ['Notice Served', 'NTS'],
                          ['Office interview', 'OFI'],
                          ['Out of hours call', 'OOC'],
                          ['Outgoing telephone call', 'OTC'],
                          ['Unsuccessful Visit', 'VIU'],
                          ['Referred for debt advice', 'DEB'],
                          ['Visit Made', 'VIM']
        ])
    end
  end
  context 'valid_code?' do
    it 'finds valid codes' do
      expect(described_class.valid_code?('WON')).to eq(true)
    end

    it 'finds invalid codes false' do
      expect(described_class.valid_code?('fake code')).to eq(false)
    end

    it 'optional checks if user_accessible' do
      expect(described_class.valid_code?('WON', user_accessible: true)).to eq(false)
      expect(described_class.valid_code?('WON', user_accessible: false)).to eq(true)
    end
  end
end