module Hackney
  module Income
    class StubSchedulerGateway
      def initialize
        @jobs = {}
      end

      def schedule_sms(run_at: Date.tomorrow.midnight, description: 'description', tenancy_ref: nil, template_id: nil)
        @jobs[tenancy_ref] ||= []
        @jobs[tenancy_ref] << { scheduled_for: run_at, description: description }
      end

      def scheduled_jobs_for(tenancy_ref:)
        @jobs.fetch(tenancy_ref, [])
      end
    end
  end
end
