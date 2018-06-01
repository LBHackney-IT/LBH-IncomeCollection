require 'rails_helper'

describe Hackney::Income::SchedulerGateway do
  let(:scheduled_job) { Delayed::Job.last }

  subject { described_class.new }

  context 'when scheduling a sms message' do
    let(:timestamp) { Date.tomorrow.noon }
    let(:description) { Faker::Lorem.word }
    let(:tenancy_ref) { Faker::Lorem.word }
    let(:template_id) { Faker::Lorem.word }

    before do
      schedule_sms(
        run_at: timestamp,
        description: description,
        tenancy_ref: tenancy_ref,
        template_id: template_id
      )
    end

    it 'should schedule the job for the correct time' do
      expect(scheduled_job.run_at).to eq(timestamp)

      expect(scheduled_job.handler).to include('job_class: SendSmsJob')
      expect(scheduled_job.handler).to include("description: #{description}")
      expect(scheduled_job.handler).to include("tenancy_ref: #{tenancy_ref}")
      expect(scheduled_job.handler).to include("template_id: #{template_id}")
    end
  end

  context 'when retrieving scheduled jobs for a tenancy' do
    let(:scheduled_jobs) { subject.scheduled_jobs_for(tenancy_ref: '123456/01') }

    context 'and there are no relevant jobs' do
      it 'should return no jobs' do
        expect(scheduled_jobs).to be_empty
      end
    end

    context 'and the tenancy has scheduled jobs' do
      before do
        schedule_sms(
          run_at: Date.tomorrow.noon,
          description: 'right tenancy',
          tenancy_ref: '123456/01'
        )
      end

      it 'should return jobs' do
        expect(scheduled_jobs).to eq([{
          scheduled_for: Date.tomorrow.noon,
          description: 'right tenancy'
        }])
      end

      context 'and other tenancies have scheduled jobs' do
        before do
          schedule_sms(tenancy_ref: '234567/01', description: 'wrong tenancy')
          schedule_sms(tenancy_ref: '123456/01', description: 'right tenancy')
        end

        it 'should only include jobs for the right tenancy' do
          expect(scheduled_jobs).to all(include(description: 'right tenancy'))
        end

        it 'should include all jobs for that tenancy' do
          expect(scheduled_jobs.count).to eq(2)
        end
      end
    end
  end

  def schedule_sms(run_at: Date.tomorrow.noon, description: 'description', tenancy_ref: '1234567/01', template_id: 'test-template-id')
    subject.schedule_sms(
      run_at: run_at,
      description: description,
      tenancy_ref: tenancy_ref,
      template_id: template_id
    )
  end
end
