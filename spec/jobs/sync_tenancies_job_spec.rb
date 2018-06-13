require 'rails_helper'

describe SyncTenanciesJob do
  let(:stub_tenancy_gateway_class) { Hackney::Income::StubTenancyGatewayBuilder.build_stub(with_tenancies: []) }
  let(:stub_transactions_gateway_class) { Hackney::Income::StubTransactionsGateway }

  before do
    stub_const('Hackney::Income::ReallyDangerousTenancyGateway', stub_tenancy_gateway_class)
    stub_const('Hackney::Income::TransactionsGateway', stub_transactions_gateway_class)

    ActiveJob::Base.queue_adapter = :test
  end

  after do
    ActiveJob::Base.queue_adapter = Rails.application.config.active_job.queue_adapter
  end

  subject { described_class.perform_now }

  context 'when no remote tenancies are available' do
    it 'should log that there were no remote tenancies' do
      expect_logged('[SyncTenanciesJob] Synced 0 tenancies from the Hackney Income API')
      subject
    end
  end

  context 'when remote tenancies are available' do
    let(:stub_tenancy_gateway_class) { Hackney::Income::StubTenancyGatewayBuilder.build_stub }

    it 'should pass them to the SyncTenancies use case' do
      expect_any_instance_of(Hackney::Income::SyncTenancies).to receive(:execute).and_return(%w[1234567 2345678 3456789])
      subject
    end

    it 'should log the correct number of remote tenancies synced' do
      expect_logged('[SyncTenanciesJob] Synced 3 tenancies from the Hackney Income API')
      subject
    end
  end

  it 'should schedule the next sync' do
    six_am_tomorrow = Date.tomorrow.to_time.advance(hours: 6)
    expect { subject }.to have_enqueued_job(described_class).at(six_am_tomorrow)
  end

  def expect_logged(message)
    allow(Rails.logger).to receive(:info)
    expect(Rails.logger).to receive(:info).with(message)
  end
end
