class ActionDiaryEntryController < ApplicationController
  def show
    # @sms_templates = list_sms_templates.execute(tenancy_ref: params.fetch(:id))
    # @tenancy = view_tenancy.execute(tenancy_ref: params.fetch(:id))
  end

  def create
    tenancy = tenancy_gateway.get_tenancy(tenancy_ref: params.fetch(:id))
    use_case = Hackney::Income::CreateActionDiaryEntry.new
    use_case.execute(tenancy_ref:1, balance:1, code:1, type:1, date:1, comment:1, universal_housing_username:1)
    # send_sms.execute(
    #   tenancy_ref: params.fetch(:id),
    #   template_id: params.fetch(:template_id)
    # )
    #
    flash[:notice] = 'Successfully created an action diary entry'
    redirect_to tenancy_path(id: params.fetch(:id))
  end

  private

  # def list_sms_templates
  #   Hackney::Income::ListSmsTemplates.new(
  #     tenancy_gateway: tenancy_gateway,
  #     notifications_gateway: notifications_gateway
  #   )
  # end
  #
  # def view_tenancy
  #   Hackney::Income::ViewTenancy.new(
  #     tenancy_gateway: tenancy_gateway,
  #     transactions_gateway: transactions_gateway,
  #     scheduler_gateway: scheduler_gateway,
  #     events_gateway: events_gateway
  #   )
  # end
  #
  # def send_sms
  #   Hackney::Income::SendSms.new(
  #     tenancy_gateway: tenancy_gateway,
  #     notification_gateway: notifications_gateway,
  #     events_gateway: events_gateway
  #   )
  # end
  #
  def tenancy_gateway
    Hackney::Income::LessDangerousTenancyGateway.new(
      api_host: ENV['INCOME_COLLECTION_API_HOST'],
      api_key: ENV['INCOME_COLLECTION_API_KEY'],
      # include_developer_data: Rails.application.config.include_developer_data?
    )
  end
  #
  # def notifications_gateway
  #   Hackney::Income::GovNotifyGateway.new(
  #     sms_sender_id: ENV['GOV_NOTIFY_SENDER_ID'],
  #     api_key: ENV['GOV_NOTIFY_API_KEY']
  #   )
  # end
  #
  # def transactions_gateway
  #   Hackney::Income::TransactionsGateway.new(
  #     api_host: ENV['INCOME_COLLECTION_API_HOST'],
  #     api_key: ENV['INCOME_COLLECTION_API_KEY'],
  #     include_developer_data: Rails.application.config.include_developer_data?
  #   )
  # end
  #
  # def scheduler_gateway
  #   Hackney::Income::SchedulerGateway.new
  # end
  #
  # def events_gateway
  #   Hackney::Income::SqlEventsGateway.new
  # end
end
