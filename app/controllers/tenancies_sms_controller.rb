class TenanciesSmsController < ApplicationController
  def show
    list_sms_templates = Hackney::Income::ListSmsTemplates.new(tenancy_gateway: tenancy_gateway, notifications_gateway: notifications_gateway)
    @sms_templates = list_sms_templates.execute(tenancy_ref: params.fetch(:id))

    view_tenancy = Hackney::Income::ViewTenancy.new(tenancy_gateway: tenancy_gateway, transactions_gateway: transactions_gateway)
    @tenancy = view_tenancy.execute(tenancy_ref: params.fetch(:id))
  end

  private

  def tenancy_gateway
    if Rails.env.development?
      Hackney::Income::TestTenancyGateway.new
    else
      Hackney::Income::ReallyDangerousTenancyGateway.new(api_host: ENV['INCOME_COLLECTION_API_HOST'])
    end
  end

  def notifications_gateway
    Hackney::Income::GovNotifyGateway.new(sms_sender_id: ENV['GOV_NOTIFY_SENDER_ID'], api_key: ENV['GOV_NOTIFY_API_KEY'])
  end

  def transactions_gateway
    if Rails.env.development?
      Hackney::Income::StubTransactionsGateway.new
    else
      Hackney::Income::TransactionsGateway.new(api_host: ENV['INCOME_COLLECTION_API_HOST'])
    end
  end
end
