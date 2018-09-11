module Hackney
  module Income
    class ActionDiaryEntryCodes
      def self.all_code_options
        [
          { name: 'Arrears Cleared', code: 'Z00', user_accessible: false },
          { name: 'Old Stage One', code: '1RS', user_accessible: false },
          { name: 'Old Stage Two', code: '2RS', user_accessible: false },
          { name: 'Agreement brought up-to-date', code: 'AGR', user_accessible: false },
          { name: 'Old Stage Three', code: '3RS', user_accessible: false },
          { name: 'Old Stage Four', code: '4RS', user_accessible: false },
          { name: 'Reset Stage Four', code: 'RR4', user_accessible: false },
          { name: 'Stage One Complete', code: 'ZR1', user_accessible: false },
          { name: 'Stage Two Complete', code: 'ZR2', user_accessible: false },
          { name: 'Stage Three Complete', code: 'ZR3', user_accessible: false },
          { name: 'Legal Referral Complete', code: 'ZL4', user_accessible: false },
          { name: 'Stage One (T)', code: '1TS', user_accessible: false },
          { name: 'Stage Two (T)', code: '2TS', user_accessible: false },
          { name: 'Eviction', code: '5TA', user_accessible: false },
          { name: 'Court Proceedings Complete', code: 'ZT4', user_accessible: false },
          { name: 'Eviction Complete', code: 'ZT5', user_accessible: false },
          { name: 'Pre-Court Complete', code: 'ZR5', user_accessible: false },
          { name: 'Old Breached Agreement (0)', code: '0RA', user_accessible: false },
          { name: 'Pre Court', code: '5RP', user_accessible: false },
          { name: 'Court Proceedings', code: '4TC', user_accessible: false },
          { name: 'Stage Four Complete', code: 'ZR4', user_accessible: false },
          { name: 'Stage One Complete', code: 'ZT1', user_accessible: false },
          { name: 'Old Breached Agreement (1)', code: '1RA', user_accessible: false },
          { name: 'Old Breached Agreement (2)', code: '2RA', user_accessible: false },
          { name: 'Old Breached Agreement (3)', code: '3RA', user_accessible: false },
          { name: 'Breached Order', code: '6RO', user_accessible: false },
          { name: 'Breached Agreement 1L', code: '1LA', user_accessible: false },
          { name: 'Stage One (L)', code: '1LS', user_accessible: false },
          { name: 'Stage Two Complete', code: 'ZT2', user_accessible: false },
          { name: 'Stage Two (L)', code: '2LS', user_accessible: false },
          { name: 'General Diary Note', code: 'GEN', user_accessible: false },
          { name: 'Stage Three (L)', code: '3LS', user_accessible: false },
          { name: 'Legal Referral', code: '4LL', user_accessible: false },
          { name: 'Breached Agreement 0L', code: '0LA', user_accessible: false },
          { name: 'Breached Agreement 3L', code: '3LA', user_accessible: false },
          { name: 'Breached Agreement 2L', code: '2LA', user_accessible: false },
          { name: 'Breached Agreement 4L', code: '4LA', user_accessible: false },
          { name: 'Stage One Complete', code: 'ZL1', user_accessible: false },
          { name: 'Stage Two Complete', code: 'ZL2', user_accessible: false },
          { name: 'Stage Three Complete', code: 'ZL3', user_accessible: false },
          { name: 'Court Proceedings Complete', code: 'ZR6', user_accessible: false },
          { name: 'Stage Three (T)', code: '3TS', user_accessible: false },
          { name: 'Breached Agreement', code: 'BRE', user_accessible: false },
          { name: 'Stage Three Complete', code: 'ZT3', user_accessible: false },
          { name: 'Outright Possession Order', code: 'OUT', user_accessible: false },
          { name: 'Unsuccessful Visit', code: 'VIU', user_accessible: true },
          { name: 'Visit Made', code: 'VIM', user_accessible: true },
          { name: 'Costs Awarded', code: 'CAW', user_accessible: false },
          { name: 'Eviction Complete', code: 'ZT6', user_accessible: false },
          { name: 'Money Judgement Awarded', code: 'MJA', user_accessible: false },
          { name: 'Charge Against Property', code: 'CAP', user_accessible: false },
          { name: 'Suspended Possession', code: 'SPO', user_accessible: false },
          { name: 'Postponed Possession', code: 'PPO', user_accessible: false },
          { name: 'Adjourned Generally', code: 'ADG', user_accessible: false },
          { name: 'Adjourned on Terms', code: 'ADT', user_accessible: false },
          { name: 'DWP Direct Payments Requested', code: 'DPQ', user_accessible: false },
          { name: 'HB Outstanding', code: 'HBO', user_accessible: true },
          { name: 'DWP Direct Payments Refused', code: 'DPR', user_accessible: false },
          { name: 'DWP Direct Payments Being Made', code: 'DPM', user_accessible: false },
          { name: 'DWP Direct Payments Terminated', code: 'DPT', user_accessible: false },
          { name: 'Money Judgement Requested', code: 'MJQ', user_accessible: false },
          { name: 'Eviction', code: 'EVI', user_accessible: false },
          { name: 'Dispute', code: 'DIS', user_accessible: false },
          { name: 'Complaint Received', code: 'CRC', user_accessible: false },
          { name: 'Complaint Resolved', code: 'CRS', user_accessible: false },
          { name: 'Notice Served', code: 'NTS', user_accessible: true },
          { name: 'Introductory Tenancy to Secure', code: 'ITS', user_accessible: false },
          { name: 'Voluntary Attach. of Earnings', code: 'VAP', user_accessible: false },
          { name: 'Involuntary Att. of Earnings', code: 'IPA', user_accessible: false },
          { name: 'Warrant of Exec. Applied for', code: 'WEA', user_accessible: false },
          { name: 'Notice of Extension Served', code: 'NES', user_accessible: false },
          { name: 'Eviction', code: '7RE', user_accessible: false },
          { name: 'Breached Agreement (1)', code: '1TA', user_accessible: false },
          { name: 'Referred to Moorcroft', code: 'DA1', user_accessible: false },
          { name: 'Direct Debit new sign up', code: 'DDR', user_accessible: false },
          { name: 'Direct Debit Cancelled', code: 'DDC', user_accessible: true },
          { name: 'Now a Former Tenants Account', code: 'FTA', user_accessible: false },
          { name: 'FTA ARREARS AGREEMENT', code: 'AGG', user_accessible: false },
          { name: 'Changes to DirectDebit payment', code: 'CDD', user_accessible: false },
          { name: 'First contact with NOK', code: 'DC1', user_accessible: false },
          { name: 'Subsequent contact with NOK', code: 'DC2', user_accessible: false },
          { name: 'Breached Agreement (2)', code: '2TA', user_accessible: false },
          { name: 'Returned by Moorcroft', code: 'RT1', user_accessible: false },
          { name: 'First FTA letter sent', code: 'C', user_accessible: false },
          { name: 'Second FTA reminder', code: 'D', user_accessible: false },
          { name: 'FTA Debt Agency warning', code: 'E', user_accessible: false },
          { name: 'Financial Inclusion Visit', code: 'FIV', user_accessible: true },
          { name: 'Financial Inclusion Call', code: 'FIC', user_accessible: true },
          { name: 'Financial Inclusion Interview', code: 'FIO', user_accessible: true },
          { name: 'Out of hours call', code: 'OOC', user_accessible: true },
          { name: 'Breached Agreement (3)', code: '3TA', user_accessible: false },
          { name: 'Office interview', code: 'OFI', user_accessible: true },
          { name: 'Diirect Debit Payment', code: 'DDP', user_accessible: false },
          { name: 'FTA Broken Agreement', code: 'BA', user_accessible: false },
          { name: 'S01 Stage One', code: 'S01', user_accessible: false },
          { name: 'S02 Stage Two', code: 'S02', user_accessible: false },
          { name: 'S03 Stage Three', code: 'S03', user_accessible: false },
          { name: 'S04 Stage Four', code: 'S04', user_accessible: false },
          { name: 'S05 Court', code: 'S05', user_accessible: false },
          { name: 'S06 Breach Court Order', code: 'S06', user_accessible: false },
          { name: 'S0A Alternative Letter', code: 'S0A', user_accessible: false },
          { name: 'Court Proceedings', code: '6RC', user_accessible: false },
          { name: 'Write Off - Uneconomical', code: 'WOA', user_accessible: false },
          { name: 'Write Off - Vulnerable/Infirm', code: 'WOB', user_accessible: false },
          { name: 'Write Off - Deceased', code: 'WOC', user_accessible: false },
          { name: 'Write Off - Address Unknown', code: 'WOE', user_accessible: false },
          { name: 'Write Off - Dispute unresolved', code: 'WOF', user_accessible: false },
          { name: 'Write Off - All action failed', code: 'WOH', user_accessible: false },
          { name: 'Write Off - FT on Prison', code: 'WOD', user_accessible: false },
          { name: 'Vunerable', code: 'VUN', user_accessible: false },
          { name: 'Eviction Complete', code: 'ZR7', user_accessible: false },
          { name: 'Referred for debt advice', code: 'DEB', user_accessible: true },
          { name: 'Repairs', code: 'REP', user_accessible: false },
          { name: 'Possible abandonment', code: 'PAB', user_accessible: false },
          { name: 'TMO a/c - no action required', code: 'TMO', user_accessible: false },
          { name: 'FTA Refund Request Letter Sent', code: 'REF', user_accessible: false },
          { name: 'Arrears mail merge letter sent', code: 'MML', user_accessible: false },
          { name: 'Universal Credit', code: 'UCC', user_accessible: false },
          { name: 'Text message sent', code: 'SMS', user_accessible: false },
          { name: 'Actual Cost Breakdown Sent', code: 'ACB', user_accessible: false },
          { name: 'TA New Account checks', code: 'TAA', user_accessible: false },
          { name: 'Outcome of rent arrears panel', code: 'RAP', user_accessible: false },
          { name: 'Pre legal action visit', code: 'PLA', user_accessible: false },
          { name: 'Pre eviction contact outcome', code: 'PEO', user_accessible: false },
          { name: 'Pre notice interview', code: 'AAD', user_accessible: false },
          { name: 'Rent Arrears Panel Outcome', code: 'RAP', user_accessible: false },
          { name: 'Referred to Credit Gee', code: 'DA4', user_accessible: false },
          { name: 'Returned by Credit Gee', code: 'RT4', user_accessible: false },
          { name: 'MW Pre Arrears Completed', code: 'ZW0', user_accessible: false },
          { name: 'MW Letter Action 1 Completed', code: 'ZW1', user_accessible: false },
          { name: 'MW Letter Action 2 Completed', code: 'ZW2', user_accessible: false },
          { name: 'MW LBA Letter Completed', code: 'ZW3', user_accessible: false },
          { name: 'MW Charges Disputed Completed', code: 'ZWD', user_accessible: false },
          { name: 'MW MCOL Completed', code: 'ZWC', user_accessible: false },
          { name: 'MW Legal Referral Completed', code: 'ZWL', user_accessible: false },
          { name: 'MW Arrangement Completed', code: 'ZWA', user_accessible: false },
          { name: 'Write on - arrears reinstated', code: 'AWO', user_accessible: false },
          { name: 'MW Arrangement Breached', code: 'MWB', user_accessible: false },
          { name: 'FTA - TO BE TRACED', code: 'NFA', user_accessible: false },
          { name: 'Incoming telephone call', code: 'INC', user_accessible: true },
          { name: 'Outgoing telephone call', code: 'OTC', user_accessible: true },
          { name: 'REFERRED TO VIL COLLECTIONS', code: 'DA2', user_accessible: false },
          { name: 'REFERRED TO LEWIS DEBT AGENCY', code: 'DA3', user_accessible: false },
          { name: 'RETURNED BY VIL COLLECTIONS', code: 'RT2', user_accessible: false },
          { name: 'RETURNED BY LEWIS DEBT AGENCY', code: 'RT3', user_accessible: false },
          { name: 'ACTION ON HOLD', code: 'INV', user_accessible: false },
          { name: 'HB INVESTIGATION PENDING', code: 'MHB', user_accessible: false },
          { name: 'Returned by Credit Gee', code: 'RT4', user_accessible: false },
          { name: 'MW Pre Arrears', code: 'MW0', user_accessible: false },
          { name: 'MW Letter Action 1', code: 'MW1', user_accessible: false },
          { name: 'MW Letter Action 2', code: 'MW2', user_accessible: false },
          { name: 'MW LBA Letter', code: 'MW3', user_accessible: false },
          { name: 'MW Charges Disputed', code: 'MWD', user_accessible: false },
          { name: 'MW MCOL', code: 'MWC', user_accessible: false },
          { name: 'MW Legal Referral', code: 'MWL', user_accessible: false },
          { name: 'MW Arrangement', code: 'MWA', user_accessible: false },
          { name: 'Arrears reinstated to offset', code: 'WON', user_accessible: false }
        ]
      end

      def self.code_dropdown_options
        res = []
        all_code_options.each do |opt|
          res << [opt[:name], opt[:code]] if opt[:user_accessible]
        end

        res.sort_by { |i| i[0] }
      end

      def self.human_readable_action_code(code)
        all_code_options.select { |e| e.fetch(:code) == code }.first.fetch(:name)
      end
    end
  end
end
