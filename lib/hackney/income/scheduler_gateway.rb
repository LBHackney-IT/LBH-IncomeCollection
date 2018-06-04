module Hackney
  module Income
    class SchedulerGateway
      def schedule_sms(run_at:, description:, tenancy_ref:, template_id:)
        SendSmsJob.set(wait_until: run_at).perform_later(
          description: description,
          tenancy_ref: tenancy_ref,
          template_id: template_id
        )
      end

      def scheduled_jobs_for(tenancy_ref:)
        jobs_for(tenancy_ref: tenancy_ref).map do |job|
          args = job_args(job)
          { scheduled_for: job.run_at, description: args.fetch('description') }
        end
      end

      private

      def jobs_for(tenancy_ref:)
        Delayed::Job.where('handler LIKE :condition', condition: "%tenancy_ref: #{tenancy_ref}%")
      end

      def job_args(job)
        YAML.safe_load(job.handler, [ActiveJob::QueueAdapters::DelayedJobAdapter::JobWrapper])
          .as_json.dig('job_data', 'arguments', 0)
      end
    end
  end
end
