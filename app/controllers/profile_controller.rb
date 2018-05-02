class ProfileController < ApplicationController

  def show
    @primary_contact = {
      title: 'Mr',
      name: 'Chris Smith',
      address: {
        address_1: '1 Test Street',
        address_2: 'Example Road',
        address_3: 'Hackney',
        address_4: 'London',
        postcode:  'E9 3PL'
      },
      contact_number: '07901234567',
      email: 'chris@example.com'
    }
  end
end
