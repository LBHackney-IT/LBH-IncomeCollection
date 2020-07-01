require 'rails_helper'

describe Hackney::Income::CreateAgreement do
  let(:create_agreement_gateway) { instance_double(Hackney::Income::CreateAgreementGateway) }
  let(:create_agreement_params) do
    {
      tenancy_ref: Faker::Lorem.characters(number: 6),
      agreement_type: 'informal',
      frequency: %w[weekly monthly].sample,
      amount: Faker::Commerce.price(range: 10...100),
      start_date: Faker::Date.between(from: 2.days.ago, to: Date.today),
      created_by: Faker::Name.name
    }
  end

  subject { described_class.new(agreement_gateway: create_agreement_gateway) }

  it 'should pass the required data through to the gateway' do
    expect(create_agreement_gateway).to receive(:create_agreement).with(create_agreement_params)
    subject.execute(create_agreement_params)
  end
end
