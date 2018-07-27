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

  it 'should use the tenancy ref as the seed when anonymizing' do
    tenancy1 = {
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

    tenancy2 = {
      primary_contact: {
        first_name: 'Different',
        last_name: 'Name',
        title: 'Mr'
      },
      address_1: 'Same',
      postcode: 'Reference number',
      tenancy_ref: '012345/01',
      current_balance: '1168.69'
    }

    seeded_name_for_tenancy_ref1 = 'Mittie'
    seeded_name_for_tenancy_ref2 = 'Brandy'
    anonymized_tenancy1 = Hackney::Income::Anonymizer.anonymize_tenancy_list_item(tenancy: tenancy1)
    anonymized_tenancy2 = Hackney::Income::Anonymizer.anonymize_tenancy_list_item(tenancy: tenancy2)

    expect(anonymized_tenancy1.dig(:primary_contact, :first_name)).to eq(seeded_name_for_tenancy_ref1)
    expect(anonymized_tenancy2.dig(:primary_contact, :first_name)).to eq(seeded_name_for_tenancy_ref2)
  end
end
