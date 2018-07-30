describe Hackney::Income::Domain::TenancyListItem do
  context 'when retrieving tenancy list items' do
    let(:subject) { described_class.new }

    before do
      subject.ref = 'FAKE/01'
      subject.current_balance = '123.45'
      subject.current_arrears_agreement_status = '101'
      subject.latest_action_code = 'GEN'
      subject.latest_action_date = '2018-01-01 00:00:00'
      subject.primary_contact_name = 'Batch Roast'
      subject.primary_contact_short_address = '123 Test Lane'
      subject.primary_contact_postcode = 'TEST'
    end

    it 'should map the received fields' do
      expect(subject).to be_instance_of(Hackney::Income::Domain::TenancyListItem)
    end

    it 'should have the required fields' do
      expect(subject).to have_attributes(ref: 'FAKE/01')
      expect(subject).to have_attributes(current_balance: '123.45')
      expect(subject).to have_attributes(current_arrears_agreement_status: '101')
      expect(subject).to have_attributes(latest_action_code: 'GEN')
      expect(subject).to have_attributes(latest_action_date: '2018-01-01 00:00:00')
      expect(subject).to have_attributes(primary_contact_name: 'Batch Roast')
      expect(subject).to have_attributes(primary_contact_short_address: '123 Test Lane')
      expect(subject).to have_attributes(primary_contact_postcode: 'TEST')
    end
  end
end
