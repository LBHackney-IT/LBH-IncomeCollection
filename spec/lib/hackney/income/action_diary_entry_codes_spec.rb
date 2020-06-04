require_relative '../../../../lib/hackney/income/action_diary_entry_codes'

describe Hackney::Income::ActionDiaryEntryCodes do
  context 'code_dropdown_options' do
    it 'finds valid codes' do
      expect(described_class.code_dropdown_options)
        .to match_array([
                          ['Covid 19 Call', 'CVD'],
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
                          ['Visit Made', 'VIM'],
                          ['Adjourned Generally', 'ADG'],
                          ['Adjourned on Terms', 'ADT'],
                          ['Charge Against Property', 'CAP'],
                          ['Court Outcome Letter', 'IC5'],
                          ['Court Warning Letter', 'IC4'],
                          ['Promise of payment', 'POP'],
                          ['Suspended Possession', 'SPO'],
                          ['Universal Credit', 'UCC'],
                          ['Costs Awarded', 'CAW'],
                          ['Court Breach Letter', 'CBL'],
                          ['Court date set', 'CDS'],
                          ['DWP Direct Payments Requested', 'DPQ'],
                          ['Delayed benefit', 'MBH'],
                          %w[Deceased DEC],
                          %w[Eviction EVI],
                          ['Eviction date set', 'EDS'],
                          ['HB INVESTIGATION PENDING', 'MHB'],
                          ['Money Judgement Awarded', 'MJA'],
                          ['Postponed Possession', 'PPO'],
                          ['Warrant of Possession', 'WPA'],
                          ['Informal Agreement Breach Letter Sent', 'BLI']
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

  context 'when displaying letter codes' do
    tests = [
      { name: 'Letter 1 in arrears FH', code: 'LF1' },
      { name: 'Letter 2 in arrears FH', code: 'LF2' },
      { name: 'Letter 1 in arrears LH', code: 'LL1' },
      { name: 'Letter 2 in arrears LH', code: 'LL2' },
      { name: 'Letter 1 in arrears SO', code: 'LS1' },
      { name: 'Letter 2 in arrears SO', code: 'LS2' },
      { name: 'Letter Before Action', code: 'SLB' },
      { name: 'Income Collection Letter 1', code: 'IC1' },
      { name: 'Income Collection Letter 2', code: 'IC2' },
      { name: 'Automated green in Arrears sms message', code: 'GAT' },
      { name: 'Automated green in Arrears email message', code: 'GAE' },
      { name: 'Manual green in Arrears email message', code: 'GME' },
      { name: 'Manual green in Arrears sms message', code: 'GMS' },
      { name: 'Manual amber in Arrears sms message', code: 'AMS' }
    ]

    tests.each do |test_case|
      it "correctly displays name for action code #{test_case[:code]}" do
        expect(described_class.human_readable_action_code(test_case[:code])).to eq(test_case[:name])
      end
    end
  end
end
