require 'rails_helper'

describe SendSmsJob do
  let(:tenancy_ref) { Faker::Lorem.word }
  let(:template_id) { Faker::Lorem.word }

  subject do
    described_class.perform_now(
      description: 'test',
      tenancy_ref: tenancy_ref,
      template_id: template_id
    )
  end

  before do
    stub_const('Hackney::Income::ReallyDangerousTenancyGateway', Hackney::Income::StubTenancyGateway)
    stub_const('Hackney::Income::GovNotifyGateway', Hackney::Income::StubNotificationsGateway)
    stub_const('Hackney::Income::SqlEventsGateway', Hackney::Income::StubEventsGateway)
  end

  context 'when running the job' do
    it 'should call the SendSms use case correctly' do
      expect_any_instance_of(Hackney::Income::SendSms).to receive(:execute).
        with(tenancy_ref: tenancy_ref, template_id: template_id)

      subject
    end
  end
end
