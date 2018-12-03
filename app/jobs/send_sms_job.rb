class SendSmsJob < ApplicationJob
  def perform(phone_numbers:, description:, tenancy_ref:, template_id:)
    send_sms.execute(phone_numbers: phone_numbers, tenancy_ref: tenancy_ref, template_id: template_id, user_id: nil)
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
    Hackney::Income::TenancyGateway.new(
      api_host: ENV['INCOME_COLLECTION_API_HOST'],
      api_key: ENV['INCOME_COLLECTION_API_KEY']
    )
  end

  def notifications_gateway
    Hackney::Income::GovNotifyGateway.new(
      sms_sender_id: ENV['GOV_NOTIFY_SENDER_ID'],
      api_key: ENV['GOV_NOTIFY_API_KEY']
    )
  end

  def events_gateway
    Hackney::Income::SqlEventsGateway.new
  end
end
