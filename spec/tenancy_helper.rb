def example_tenancy(attributes = {})
  agreements = attributes
    .fetch(:agreements, [])
    .map(&method(:example_agreement))

  arrears_actions = attributes
    .fetch(:arrears_actions, [])
    .map(&method(:example_arrears_action))

  {
    ref: attributes.fetch(:tenancy_ref, '000001/FAKE'),
    current_balance: attributes.fetch(:current_balance, '100.00'),
    type: 'SEC',
    start_date: '2018-01-01',
    priority_band: 'Green',
    primary_contact: {
      first_name: 'Waffles',
      last_name: 'The Dog',
      title: 'Ms',
      contact_number: '0208 123 1234',
      email_address: 'test@example.com'
    },
    address: {
      address_1: '136 Southwark Street',
      address_2: 'Hackney',
      address_3: 'London',
      address_4: 'UK',
      post_code: 'E1 123'
    },
    agreements: agreements,
    arrears_actions: arrears_actions
  }
end

def example_transaction(attributes = {})
  attributes.reverse_merge(
    id: '123-456-789',
    timestamp: Time.now,
    tenancy_ref: '3456789',
    description: 'Rent Payment',
    value: -50.00,
    type: 'RPY'
  )
end

def example_agreement(attributes = {})
  attributes.reverse_merge(
    status: 'active',
    type: 'court_ordered',
    value: '10.99',
    frequency: 'weekly',
    created_date: '2017-11-01'
  )
end

def example_arrears_action(attributes = {})
  attributes.reverse_merge(
    type: 'general_note',
    automated: false,
    user: { name: 'Brainiac' },
    date: Time.now.strftime('%Y-%m-%d'),
    description: 'this tenant is in arrears!'
  )
end
