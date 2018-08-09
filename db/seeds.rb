# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Hackney::Models::User.create(
  provider_uid: 'azure_activedirectory',
  provider: 'azureactivedirectory',
  name: 'Test User',
  email: 'steven@madetech.com',
  first_name: 'Test',
  last_name: 'User'
)

Hackney::Models::Tenancy.create(
  ref: '12345/01',
  assigned_user_id: 1,
  primary_contact_name: 'Mr Test Tenancy',
  primary_contact_short_address: '1, Test Lane, Delivery City',
  primary_contact_postcode: 'TE01 ST',
  current_balance: '190.00',
  latest_action_code: 'S01',
  latest_action_date: '2018-08-15',
  current_arrears_agreement_status: 'breached'
)
