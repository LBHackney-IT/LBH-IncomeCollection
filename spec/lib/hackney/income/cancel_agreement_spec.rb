require 'rails_helper'

describe Hackney::Income::CancelAgreement do
  let(:agreement_gateway) { instance_double(Hackney::Income::AgreementsGateway) }
  let(:agreement_id) { Faker::Lorem.characters(number: 6) }
  let(:cancellation_reason) { Faker::Lorem.characters(number: 40) }
  let(:cancelled_by) { Faker::Name.name }

  subject { described_class.new(agreement_gateway: agreement_gateway) }

  it 'should pass the required param to the gateway' do
    expect(agreement_gateway).to receive(:cancel_agreement).with(
      agreement_id: agreement_id,
      cancelled_by: cancelled_by,
      cancellation_reason: cancellation_reason
    )
    subject.execute(agreement_id: agreement_id, cancelled_by: cancelled_by, cancellation_reason: cancellation_reason)
  end
end
