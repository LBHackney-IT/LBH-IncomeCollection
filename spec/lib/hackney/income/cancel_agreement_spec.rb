require 'rails_helper'

describe Hackney::Income::CancelAgreement do
  let(:agreement_gateway) { instance_double(Hackney::Income::AgreementsGateway) }
  let(:agreement_id) { Faker::Lorem.characters(number: 6) }

  subject { described_class.new(agreement_gateway: agreement_gateway) }

  it 'should pass the required param to the gateway' do
    expect(agreement_gateway).to receive(:cancel_agreement).with(agreement_id: agreement_id)
    subject.execute(agreement_id: agreement_id)
  end
end
