namespace :stub_data do
  desc 'Create scheduled tasks for developer tenancies'
  task scheduled_tasks: :environment do
    tenancies = %w(0000001/FAKE)
    scheduler = Hackney::Income::SchedulerGateway.new

    tenancies.each do |tenancy_ref|
      scheduler.schedule_sms(
        run_at: Time.now + 1.year,
        description: 'Send SMS message: "Arrears Notification"',
        tenancy_ref: tenancy_ref,
        template_id: 'b3daa233-3e13-405f-ad09-1dfa0fa9f955'
      )

      puts "~> Created a scheduled action for #{tenancy_ref}"
    end
  end
end
