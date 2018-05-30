class TenanciesSmsController < ApplicationController
  def show
    list_sms_templates = Hackney::Income::ListSmsTemplates.new(tenancy_gateway: tenancy_gateway, notifications_gateway: notifications_gateway)
    @sms_templates = list_sms_templates.execute(tenancy_ref: params.fetch(:id))
    @tenancy = view_tenancy_use_case.execute(tenancy_ref: params.fetch(:id))
  end

  def create
    send_sms_use_case.execute(
      tenancy_ref: params.fetch(:id),
      template_id: params.fetch(:template_id)
    )

    flash[:notice] = 'Successfully sent the tenant an SMS message'
    redirect_to tenancy_path(id: params.fetch(:id))
  end

  private

  def tenancy_gateway
    Hackney::Income::ReallyDangerousTenancyGateway.new(
      api_host: ENV['INCOME_COLLECTION_API_HOST'],
      include_developer_data: Rails.application.config.include_developer_data?
    )
  end

  def notifications_gateway
    Hackney::Income::GovNotifyGateway.new(
      sms_sender_id: ENV['GOV_NOTIFY_SENDER_ID'],
      api_key: ENV['GOV_NOTIFY_API_KEY'],
      email_reply_to_id: nil
    )
  end

  def transactions_gateway
    Hackney::Income::TransactionsGateway.new(
      api_host: ENV['INCOME_COLLECTION_API_HOST'],
      include_developer_data: Rails.application.config.include_developer_data?
    )
  end

  def scheduler_gateway
    Hackney::Income::SchedulerGateway.new
  end

  def events_gateway
    Hackney::Income::SqlEventsGateway.new
  end

  def view_tenancy_use_case
    Hackney::Income::ViewTenancy.new(tenancy_gateway: tenancy_gateway, transactions_gateway: transactions_gateway, scheduler_gateway: scheduler_gateway)
  end

  def send_sms_use_case
    Hackney::Income::SendSms.new(tenancy_gateway: tenancy_gateway, notification_gateway: notifications_gateway, events_gateway: events_gateway)
  end
end
