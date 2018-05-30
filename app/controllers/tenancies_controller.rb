class TenanciesController < ApplicationController
  def index
    list_tenancies = Hackney::Income::ListTenanciesInArrears.new(tenancy_gateway: tenancy_gateway)
    @tenancies_in_arrears = list_tenancies.execute
  end

  def show
    view_tenancy = Hackney::Income::ViewTenancy.new(tenancy_gateway: tenancy_gateway, transactions_gateway: transactions_gateway, scheduler_gateway: scheduler_gateway)
    @tenancy = view_tenancy.execute(tenancy_ref: params.fetch(:id))
  end

  private

  def tenancy_gateway
    Hackney::Income::ReallyDangerousTenancyGateway.new(
      api_host: ENV['INCOME_COLLECTION_API_HOST'],
      include_developer_data: Rails.application.config.include_developer_data?
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
end
