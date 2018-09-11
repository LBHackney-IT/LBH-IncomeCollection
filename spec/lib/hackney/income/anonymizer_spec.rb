describe Hackney::Income::Anonymizer do
  it 'should be able to anonymize each item in a tenancy list' do
    tenancy = Hackney::Income::Domain::TenancyListItem.new

    tenancy.ref = '012345/01'
    tenancy.current_balance = '1168.69'
    tenancy.primary_contact_name = 'Mr S Leighton'
    tenancy.primary_contact_short_address = '1 Awesome Road'
    tenancy.primary_contact_postcode = 'EC21'

    anonymized_tenancy = Hackney::Income::Anonymizer.anonymize_tenancy_list_item(tenancy: tenancy)

    expect(anonymized_tenancy.primary_contact_name).to_not eq('Mr S Leighton')
    expect(anonymized_tenancy.primary_contact_short_address).to_not eq('1 Awesome Road')
    expect(anonymized_tenancy.primary_contact_postcode).to_not eq('EC21')
    expect(anonymized_tenancy.current_balance).to eq('1168.69')
  end

  it 'should be able to anonymize individual tenancies' do
    tenancy = Hackney::Income::Domain::Tenancy.new

    tenancy.primary_contact_name = 'Mr Steven Leighton'
    tenancy.primary_contact_long_address = '1 Awesome Road'
    tenancy.primary_contact_postcode = 'EC12'

    anonymized_tenancy = Hackney::Income::Anonymizer.anonymize_tenancy(tenancy: tenancy)

    expect(anonymized_tenancy.primary_contact_name).to_not eq('Mr Steven Leighton')
    expect(anonymized_tenancy.primary_contact_long_address).to_not eq('1 Awesome Road')
    expect(anonymized_tenancy.primary_contact_postcode).to_not eq('EC12')
  end

  it 'should use the tenancy ref as the seed when anonymizing' do
    tenancy1 = Hackney::Income::Domain::TenancyListItem.new

    tenancy1.ref = '012345/01'
    tenancy1.current_balance = '1168.69'
    tenancy1.primary_contact_name = 'Mr S Leighton'
    tenancy1.primary_contact_short_address = '1 Awesome Road'
    tenancy1.primary_contact_postcode = 'EC21'

    tenancy2 = Hackney::Income::Domain::TenancyListItem.new

    tenancy2.ref = '023456/01'
    tenancy2.current_balance = '1168.69'
    tenancy2.primary_contact_name = 'Mr Different Name'
    tenancy2.primary_contact_short_address = 'Same'
    tenancy2.primary_contact_postcode = 'Reference number'

    seeded_name_for_tenancy_ref1 = 'Dr. Brielle Friesen'
    seeded_name_for_tenancy_ref2 = 'Mr. Crystal Larson'
    anonymized_tenancy1 = Hackney::Income::Anonymizer.anonymize_tenancy_list_item(tenancy: tenancy1)
    anonymized_tenancy2 = Hackney::Income::Anonymizer.anonymize_tenancy_list_item(tenancy: tenancy2)

    expect(anonymized_tenancy1.primary_contact_name).to eq(seeded_name_for_tenancy_ref1)
    expect(anonymized_tenancy2.primary_contact_name).to eq(seeded_name_for_tenancy_ref2)
  end
end
