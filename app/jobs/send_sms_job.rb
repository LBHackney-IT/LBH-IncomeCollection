class SendSmsJob < ApplicationJob
  def perform(description:, tenancy_ref:, template_id:)
    send_sms.execute(tenancy_ref: tenancy_ref, template_id: template_id)
  end

  private

  def send_sms
    Hackney::Income::SendSms.new(
      tenancy_gateway: tenancy_gateway,
      notification_gateway: notifications_gateway,
      events_gateway: events_gateway
    )
  end

  def tenancy_gateway
    Hackney::Income::ReallyDangerousTenancyGateway.new(
      api_host: ENV['INCOME_COLLECTION_API_HOST'],
      include_developer_data: Rails.application.config.include_developer_data?
    )
  end

  def notifications_gateway
    Hackney::Income::GovNotifyGateway.new(sms_sender_id: ENV['GOV_NOTIFY_SENDER_ID'], api_key: ENV['GOV_NOTIFY_API_KEY'])
  end

  def events_gateway
    Hackney::Income::SqlEventsGateway.new
  end
end
