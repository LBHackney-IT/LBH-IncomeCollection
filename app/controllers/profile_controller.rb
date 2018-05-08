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

    @action_diary = [
      {
        action: 'General Note',
        date: '2018-01-30',
        description: 'Called customer, agreed to pay off outstanding balance next day'
      }
    ]

    @payments = [
      {
        date: '2018-02-01',
        amount: 5000,
        type: 'DD',
        balance: 0
      },
      {
        date: '2018-01-30',
        amount: 2500,
        type: 'DD',
        balance: -5000
      }
    ]
  end
end
