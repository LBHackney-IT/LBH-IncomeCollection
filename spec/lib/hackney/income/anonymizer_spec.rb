describe Hackney::Income::Anonymizer do
  it 'should be able to anonymize each item in a tenancy list' do
    tenancy = {
      primary_contact: {
        first_name: 'Steven',
        last_name: 'Leighton',
        title: 'Mr'
      },
      address_1: '1 Awesome Road',
      postcode: 'EC21',
      tenancy_ref: '012345/01',
      current_balance: '1168.69'
    }
    anonymized_tenancy = Hackney::Income::Anonymizer.anonymize_tenancy_list_item(tenancy: tenancy)

    expect(anonymized_tenancy.dig(:primary_contact, :first_name)).to_not eq('Steven')
    expect(anonymized_tenancy.dig(:primary_contact, :last_name)).to_not eq('Leighton')

    expect(anonymized_tenancy.fetch(:address_1)).to_not eq('1 Awesome Road')
    expect(anonymized_tenancy.fetch(:postcode)).to_not eq('EC21')
  end

  it 'should be able to anonymize individual tenancies' do
    tenancy = {
      primary_contact: {
        first_name: 'Steven',
        last_name: 'Leighton',
        title: 'Mr'
      },
      address: {
        address_1: '1 Awesome Road',
        postcode: 'EC12'
      }
    }

    anonymized_tenancy = Hackney::Income::Anonymizer.anonymize_tenancy(tenancy: tenancy)

    expect(anonymized_tenancy.dig(:primary_contact, :first_name)).to_not eq('Steven')
    expect(anonymized_tenancy.dig(:primary_contact, :last_name)).to_not eq('Leighton')
    expect(anonymized_tenancy.dig(:primary_contact, :address_1)).to_not eq('1 Awesome Road')
    expect(anonymized_tenancy.dig(:primary_contact, :postcode)).to_not eq('EC12')
  end
end
