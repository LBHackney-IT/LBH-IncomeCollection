class TenanciesEmailController < ApplicationController
  def show
    @email_templates = list_email_templates.execute(tenancy_ref: params.fetch(:id))
    @tenancy = view_tenancy.execute(tenancy_ref: params.fetch(:id))
  end

  def create
    send_email.execute(
      tenancy_ref: params.fetch(:id),
      template_id: params.fetch(:template_id)
    )

    flash[:notice] = 'Successfully sent the tenant an Email'
    redirect_to tenancy_path(id: params.fetch(:id))
  end

  private

  def view_tenancy
    Hackney::Income::ViewTenancy.new(
      tenancy_gateway: tenancy_gateway,
      transactions_gateway: transactions_gateway,
      scheduler_gateway: scheduler_gateway,
      events_gateway: events_gateway
    )
  end

  def send_email
    Hackney::Income::SendEmail.new(
      tenancy_gateway: tenancy_gateway,
      notification_gateway: notifications_gateway
    )
  end

  def list_email_templates
    Hackney::Income::ListEmailTemplates.new(
      tenancy_gateway: tenancy_gateway,
      notifications_gateway: notifications_gateway
    )
  end

  def tenancy_gateway
    Hackney::Income::ReallyDangerousTenancyGateway.new(
      api_host: ENV['INCOME_COLLECTION_API_HOST'],
      include_developer_data: include_developer_data?
    )
  end

  def notifications_gateway
    Hackney::Income::GovNotifyGateway.new(
      sms_sender_id: ENV['GOV_NOTIFY_SENDER_ID'],
      api_key: ENV['GOV_NOTIFY_API_KEY']
    )
  end

  def transactions_gateway
    Hackney::Income::TransactionsGateway.new(
      api_host: ENV['INCOME_COLLECTION_API_HOST'],
      include_developer_data: include_developer_data?
    )
  end

  def include_developer_data?
    Rails.env.development? || Rails.env.staging?
  end

  def scheduler_gateway
    Hackney::Income::SchedulerGateway.new
  end

  def events_gateway
    Hackney::Income::SqlEventsGateway.new
  end
end
